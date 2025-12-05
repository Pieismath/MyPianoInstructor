//
//  FallingNotesView.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/20/25.
//
import SwiftUI

struct FallingNotesView: View {

    let notes: [NoteEvent]
    let currentTime: TimeInterval
    let lookahead: TimeInterval

    private let noteWidthFactor: CGFloat = 0.55

    var body: some View {
        GeometryReader { geo in

            let whiteKeys = PianoKeyHelper.whiteKeyMIDIs
            let whiteWidth = geo.size.width / CGFloat(whiteKeys.count)

            Canvas { context, size in
                for note in notes {

                    // ----------------------------------------
                    // SAFETY CHECK #1 (new! prevents “dumping”)
                    // ----------------------------------------
                    if note.startTime < currentTime - 0.1 {
                        continue
                    }

                    // TIME WINDOW FILTERS
                    let timeUntilHit = note.startTime - currentTime

                    if timeUntilHit > lookahead { continue }
                    if currentTime > note.startTime + note.duration { continue }

                    // FALL PROGRESS
                    let clamped = max(0, min(timeUntilHit, lookahead))
                    let progress = 1 - CGFloat(clamped / lookahead)

                    let y = size.height * progress

                    // NOTE HEIGHT BASED ON DURATION
                    let noteHeight = max(16, size.height * CGFloat(note.duration) / lookahead)

                    // X POSITION
                    let x = xPosition(
                        forPitch: note.pitch,
                        whiteKeys: whiteKeys,
                        whiteKeyWidth: whiteWidth
                    )

                    let width = whiteWidth * noteWidthFactor

                    let rect = CGRect(
                        x: x - width / 2,
                        y: y - noteHeight / 2,
                        width: width,
                        height: noteHeight
                    )

                    context.fill(Path(rect), with: .color(Color.blue.opacity(0.75)))
                }
            }
        }
    }

    private func xPosition(
        forPitch pitch: Int,
        whiteKeys: [Int],
        whiteKeyWidth: CGFloat
    ) -> CGFloat {

        if PianoKeyHelper.isWhite(pitch),
           let index = whiteKeys.firstIndex(of: pitch) {
            return CGFloat(index) * whiteKeyWidth + whiteKeyWidth / 2
        }

        let lowerWhite = pitch - 1
        if let idx = whiteKeys.firstIndex(of: lowerWhite) {
            return CGFloat(idx) * whiteKeyWidth + whiteKeyWidth * 0.75
        }

        return 0
    }
}
