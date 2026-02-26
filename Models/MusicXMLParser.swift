//
//  MusicXMLParser.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 12/2/25.
//

import Foundation

struct MusicXMLParser {
    static func parse(data: Data) -> PlaybackData {
        let delegate = MusicXMLParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        
        if parser.parse() {
            return delegate.buildPlaybackData()
        } else {
            print("MusicXML parse error:", parser.parserError?.localizedDescription ?? "unknown error")
            return delegate.fallbackPlaybackData()
        }
    }
}

private class MusicXMLParserDelegate: NSObject, XMLParserDelegate {

    private struct ParsedNote {
        var pitches: [Int]
        let startTick: Int
        var durationTicks: Int
        var voice: Int = 1
        var isTieStart: Bool = false
        var isTieStop: Bool = false
    }

    private struct ParsedPedal {
        let tick: Int
        let isDown: Bool
    }

    private(set) var divisions: Int = 1
    private(set) var tempoBPM: Double = 120.0
    private var parsedNotes: [ParsedNote] = []
    private var parsedPedals: [ParsedPedal] = []

    private var currentTick: Int = 0
    private var currentElement: String?
    private var currentText: String = ""

    // Element stack to track nesting context
    private var elementStack: [String] = []

    private var inNote = false
    private var inBackup = false
    private var inForward = false

    private var noteIsRest = false
    private var noteIsChord = false
    private var noteStep: String?
    private var noteAlter: Int = 0
    private var noteOctave: Int?
    private var noteDurationTicks: Int = 0
    private var noteVoice: String = "1"
    private var noteStaff: String?
    private var noteIsTieStart = false
    private var noteIsTieStop = false

    private var backupDurationTicks: Int = 0
    private var forwardDurationTicks: Int = 0

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        elementStack.append(name)
        currentElement = name
        currentText = ""

        switch name {
        case "note":
            inNote = true
            noteIsRest = false
            noteIsChord = false
            noteStep = nil
            noteAlter = 0
            noteOctave = nil
            noteDurationTicks = 0
            noteVoice = "1"
            noteStaff = nil
            noteIsTieStart = false
            noteIsTieStop = false

        case "backup":
            inBackup = true
            backupDurationTicks = 0

        case "forward":
            inForward = true
            forwardDurationTicks = 0

        case "sound":
            if let tempoStr = attributeDict["tempo"], let t = Double(tempoStr) {
                tempoBPM = t
            }

        case "chord":
            noteIsChord = true

        case "rest":
            noteIsRest = true

        case "tie":
            // <tie type="start"/> or <tie type="stop"/>
            if let type = attributeDict["type"] {
                if type == "start" { noteIsTieStart = true }
                if type == "stop"  { noteIsTieStop = true }
            }

        case "pedal":
            if let type = attributeDict["type"] {
                let isDown = (type == "start")
                parsedPedals.append(ParsedPedal(tick: currentTick, isDown: isDown))
            }

        default: break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName qName: String?) {
        let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)

        switch name {
        case "divisions":
            if let d = Int(trimmed) { divisions = max(d, 1) }

        case "duration":
            if let ticks = Int(trimmed) {
                if inBackup       { backupDurationTicks = ticks }
                else if inForward { forwardDurationTicks = ticks }
                else if inNote    { noteDurationTicks = ticks }
            }

        case "step":
            if inNote { noteStep = trimmed }

        case "alter":
            if inNote, let a = Int(trimmed) { noteAlter = a }

        case "octave":
            if inNote, let o = Int(trimmed) { noteOctave = o }

        case "voice":
            if inNote && !trimmed.isEmpty { noteVoice = trimmed }

        case "staff":
            if inNote && !trimmed.isEmpty { noteStaff = trimmed }

        case "backup":
            currentTick = max(0, currentTick - backupDurationTicks)
            inBackup = false

        case "forward":
            currentTick += forwardDurationTicks
            inForward = false

        case "note":
            finalizeNote()
            inNote = false

        default: break
        }

        if !elementStack.isEmpty { elementStack.removeLast() }
        currentElement = elementStack.last
        currentText = ""
    }

    private func finalizeNote() {
        if noteIsRest {
            if !noteIsChord { currentTick += noteDurationTicks }
            return
        }
        guard let step = noteStep, let octave = noteOctave else { return }

        let midiPitch = midiNumber(step: step, alter: noteAlter, octave: octave)

        if noteIsChord {
            if var last = parsedNotes.popLast() {
                last.pitches.append(midiPitch)
                // Propagate tie info for chord notes too
                if noteIsTieStart { last.isTieStart = true }
                if noteIsTieStop  { last.isTieStop = true }
                parsedNotes.append(last)
            }
            return
        }

        parsedNotes.append(ParsedNote(
            pitches: [midiPitch],
            startTick: currentTick,
            durationTicks: noteDurationTicks,
            voice: Int(noteVoice) ?? 1,
            isTieStart: noteIsTieStart,
            isTieStop: noteIsTieStop
        ))
        currentTick += noteDurationTicks
    }

    private func midiNumber(step: String, alter: Int, octave: Int) -> Int {
        let base: Int
        switch step {
        case "C": base = 0; case "D": base = 2; case "E": base = 4
        case "F": base = 5; case "G": base = 7; case "A": base = 9
        case "B": base = 11; default: base = 0
        }
        return max(21, min(108, 12 * (octave + 1) + base + alter))
    }

    func buildPlaybackData() -> PlaybackData {
        let tempo = tempoBPM > 0 ? tempoBPM : 120.0
        let beatsPerTick = 1.0 / Double(divisions)
        let secPerBeat = 60.0 / tempo

        // --- Step 1: Merge tied notes ---
        // Tied notes: a note with tie-start followed by one with tie-stop on the same pitch
        // should become a single longer note. We merge by extending the tie-start note's duration
        // and removing the tie-stop note.

        // First expand chords into individual pitch entries for tie merging
        struct FlatNote {
            let pitch: Int
            let startTick: Int
            var durationTicks: Int
            let voice: Int
            var isTieStart: Bool
            var isTieStop: Bool
        }

        var flatNotes: [FlatNote] = []
        for n in parsedNotes {
            for pitch in n.pitches {
                flatNotes.append(FlatNote(
                    pitch: pitch,
                    startTick: n.startTick,
                    durationTicks: n.durationTicks,
                    voice: n.voice,
                    isTieStart: n.isTieStart,
                    isTieStop: n.isTieStop
                ))
            }
        }

        // Merge ties: for each tie-stop note, find the matching tie-start note
        // (same pitch, same voice, whose end tick matches this note's start tick)
        // and extend the start note's duration, then mark the stop note as consumed.
        var consumed = Set<Int>()  // indices to skip

        for i in 0..<flatNotes.count {
            if consumed.contains(i) { continue }
            if !flatNotes[i].isTieStop { continue }

            let stopNote = flatNotes[i]
            // Look backwards for the matching tie-start
            for j in stride(from: i - 1, through: 0, by: -1) {
                if consumed.contains(j) { continue }
                let candidate = flatNotes[j]
                if candidate.pitch == stopNote.pitch &&
                   candidate.voice == stopNote.voice &&
                   candidate.isTieStart {
                    // Check that the start note ends where the stop note begins
                    let startEndTick = candidate.startTick + candidate.durationTicks
                    if startEndTick == stopNote.startTick {
                        // Merge: extend the start note, consume the stop note
                        flatNotes[j].durationTicks += stopNote.durationTicks
                        // If the stop note is also a tie-start (chain), propagate
                        flatNotes[j].isTieStart = stopNote.isTieStart
                        consumed.insert(i)
                        break
                    }
                }
            }
        }

        // --- Step 2: Build NoteEvents ---
        var notes: [NoteEvent] = []
        var maxEndTime: TimeInterval = 0

        for (i, n) in flatNotes.enumerated() {
            if consumed.contains(i) { continue }

            let startSec = Double(n.startTick) * beatsPerTick * secPerBeat
            let durSec = Double(n.durationTicks) * beatsPerTick * secPerBeat

            notes.append(NoteEvent(pitch: n.pitch, startTime: startSec, duration: durSec, voice: n.voice))
            maxEndTime = max(maxEndTime, startSec + durSec)
        }

        // --- Step 3: Build Pedals ---
        var pedals: [PedalEvent] = []
        for p in parsedPedals {
            let startSec = Double(p.tick) * beatsPerTick * secPerBeat
            pedals.append(PedalEvent(startTime: startSec, isDown: p.isDown))
        }

        let sortedNotes = notes.sorted { $0.startTime < $1.startTime }
        let sortedPedals = pedals.sorted { $0.startTime < $1.startTime }

        return PlaybackData(
            tempo: tempo,
            totalDuration: maxEndTime,
            notes: sortedNotes,
            pedalEvents: sortedPedals
        )
    }

    func fallbackPlaybackData() -> PlaybackData {
        return PlaybackData(tempo: 120, totalDuration: 1.0, notes: [NoteEvent(pitch: 60, startTime: 0, duration: 0.5)])
    }
}
