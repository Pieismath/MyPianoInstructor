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
            print("MusicXML parse error:", parser.parserError ?? NSError())
            return delegate.fallbackPlaybackData()
        }
    }
}

// MARK: - Internal Delegate

private class MusicXMLParserDelegate: NSObject, XMLParserDelegate {

    // Parsed note in tick-space
    private struct ParsedNote {
        var pitches: [Int]
        let startTick: Int
        let durationTicks: Int
    }

    // Global score state
    private(set) var divisions: Int = 1
    private(set) var tempoBPM: Double = 120.0
    private var parsedNotes: [ParsedNote] = []

    // Single global timeline in ticks for this part
    private var currentTick: Int = 0

    // Current XML context
    private var currentElement: String?
    private var currentText: String = ""

    // Note-level state
    private var inNote = false
    private var inBackup = false

    private var noteIsRest = false
    private var noteIsChord = false
    private var noteStep: String?
    private var noteAlter: Int = 0
    private var noteOctave: Int?
    private var noteDurationTicks: Int = 0
    private var noteVoice: String = "1"   // still parsed, but not used for timing
    private var noteStaff: String?        // same here, kept if you want later

    private var backupDurationTicks: Int = 0

    // MARK: - XMLParserDelegate

    func parser(
        _ parser: XMLParser,
        didStartElement name: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
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

        case "backup":
            inBackup = true
            backupDurationTicks = 0

        case "sound":
            if let tempoStr = attributeDict["tempo"],
               let t = Double(tempoStr) {
                tempoBPM = t
            }

        case "chord":
            noteIsChord = true

        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Collect text content (can be called multiple times)
        currentText += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement name: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)

        switch name {

        case "divisions":
            if let d = Int(trimmed) {
                divisions = max(d, 1)
            }

        case "duration":
            if let ticks = Int(trimmed) {
                if inBackup {
                    backupDurationTicks = ticks
                } else if inNote {
                    noteDurationTicks = ticks
                }
            }

        case "forward":
            if let ticks = Int(trimmed) {
                currentTick += ticks
            }

        case "step":
            noteStep = trimmed

        case "alter":
            if let a = Int(trimmed) {
                noteAlter = a
            }

        case "octave":
            if let o = Int(trimmed) {
                noteOctave = o
            }

        case "voice":
            if !trimmed.isEmpty {
                noteVoice = trimmed
            }

        case "staff":
            if !trimmed.isEmpty {
                noteStaff = trimmed
            }

        case "rest":
            // <rest/> inside <note>
            noteIsRest = true

        case "backup":
            // Move the global timeline backwards
            currentTick = max(0, currentTick - backupDurationTicks)
            inBackup = false

        case "note":
            finalizeNote()
            inNote = false

        default:
            break
        }

        currentElement = nil
        currentText = ""
    }

    // MARK: - Note Finalization
    private func finalizeNote() {

        // --- REST HANDLING ---
        if noteIsRest {
            if !noteIsChord {
                currentTick += noteDurationTicks
            }
            return
        }

        // --- PITCH EXTRACTION ---
        guard let step = noteStep,
              let octave = noteOctave else {
            return
        }

        let midiPitch = midiNumber(step: step, alter: noteAlter, octave: octave)

        // --- CHORD HANDLING ---
        if noteIsChord {
            // Attach this pitch to the previous ParsedNote
            if var last = parsedNotes.popLast() {
                last.pitches.append(midiPitch)
                parsedNotes.append(last)
            } else {
                print("Warning: <chord/> encountered but no previous note found.")
            }
            return
        }

        // --- NEW NOTE ---
        let startTick = currentTick

        let newNote = ParsedNote(
            pitches: [midiPitch],
            startTick: startTick,
            durationTicks: noteDurationTicks
        )

        parsedNotes.append(newNote)

        // --- ADVANCE TIME ONLY FOR NON-CHORD ---
        currentTick += noteDurationTicks
    }

    // MARK: - Helpers

    private func midiNumber(step: String, alter: Int, octave: Int) -> Int {
        let base: Int
        switch step {
        case "C": base = 0
        case "D": base = 2
        case "E": base = 4
        case "F": base = 5
        case "G": base = 7
        case "A": base = 9
        case "B": base = 11
        default:  base = 0
        }
        // Standard MIDI formula: pitch = 12 * (octave + 1) + base + alter
        let midi = 12 * (octave + 1) + base + alter
        // Clamp to piano range just in case
        return max(21, min(108, midi))
    }

    // MARK: - Build PlaybackData

    func buildPlaybackData() -> PlaybackData {
        let tempo = tempoBPM > 0 ? tempoBPM : 120.0

        // MusicXML: tick → beat → seconds
        let beatsPerTick = 1.0 / Double(divisions)
        let secPerBeat = 60.0 / tempo

        var events: [NoteEvent] = []
        var maxEndTime: TimeInterval = 0

        for n in parsedNotes {
            for pitch in n.pitches {
                let startSec = Double(n.startTick) * beatsPerTick * secPerBeat
                let durSec   = Double(n.durationTicks) * beatsPerTick * secPerBeat

                let event = NoteEvent(
                    pitch: pitch,
                    startTime: startSec,
                    duration: durSec
                )
                events.append(event)
                maxEndTime = max(maxEndTime, startSec + durSec)
            }
        }

        if events.isEmpty {
            return fallbackPlaybackData()
        }

        let sorted = events.sorted { $0.startTime < $1.startTime }

        return PlaybackData(
            tempo: tempo,
            totalDuration: maxEndTime,
            notes: sorted
        )
    }

    // MARK: - Fallback (if parsing fails or no notes)

    func fallbackPlaybackData() -> PlaybackData {
        let tempo: Double = 120
        let basePitch = 60
        let noteDur: TimeInterval = 0.5
        var notes: [NoteEvent] = []

        for i in 0..<8 {
            let start = Double(i) * noteDur
            notes.append(
                NoteEvent(
                    pitch: basePitch + i,
                    startTime: start,
                    duration: noteDur
                )
            )
        }

        return PlaybackData(
            tempo: tempo,
            totalDuration: Double(notes.count) * noteDur,
            notes: notes
        )
    }
}
