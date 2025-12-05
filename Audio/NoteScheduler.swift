//
//  NoteScheduler.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//

import Foundation

class NoteScheduler {

    private var timers: [Timer] = []
    private var pausedAt: TimeInterval = 0

    func schedule(playback: PlaybackData, fromTime startTime: TimeInterval) {
        cancel() // Clear old timers

        for note in playback.notes {
            let noteStart = note.startTime
            let noteEnd = note.startTime + note.duration

            // If the note already ended → do nothing
            if noteEnd <= startTime { continue }

            // START TIME
            let delayStart = max(0, noteStart - startTime)

            let startTimer = Timer.scheduledTimer(withTimeInterval: delayStart, repeats: false) { _ in
                AudioEngineManager.shared.play(note: note.pitch)
            }

            // END TIME
            let delayEnd = max(0, noteEnd - startTime)

            let stopTimer = Timer.scheduledTimer(withTimeInterval: delayEnd, repeats: false) { _ in
                AudioEngineManager.shared.stop(note: note.pitch)
            }

            timers.append(startTimer)
            timers.append(stopTimer)
        }
    }

    func pause(at time: TimeInterval) {
        pausedAt = time
        cancel()
    }

    func cancel() {
        timers.forEach { $0.invalidate() }
        timers.removeAll()
    }
}
