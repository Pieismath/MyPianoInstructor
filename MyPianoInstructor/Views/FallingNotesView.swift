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
    
    // Map MIDI pitches to horizontal positions
    let minPitch: Int = 60    // middle C
    let maxPitch: Int = 72    // one octave above
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ZStack {
                ForEach(notes) { note in
                    if let frame = frameFor(note: note, in: width, height: height) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue.opacity(0.7))
                            .frame(width: frame.width, height: frame.height)
                            .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
        }
        .background(Color.black.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func frameFor(note: NoteEvent, in width: CGFloat, height: CGFloat) -> CGRect? {
        // time until this note reaches the keyboard line
        let timeUntilHit = note.startTime - currentTime
        
        // Only show notes that are within the visible window above the keyboard
        guard timeUntilHit <= lookahead,
              timeUntilHit >= -note.duration else {
            return nil
        }
        
        // Vertical mapping:
        //   timeUntilHit = lookahead  -> top of view
        //   timeUntilHit = 0          -> bottom of view (just above keys)
        let progress = 1.0 - CGFloat((timeUntilHit + note.duration) / (lookahead + note.duration))
        let y = height * progress
        
        let noteHeight = max(8, height * CGFloat(note.duration) / CGFloat(lookahead + 0.5))
        
        // Horizontal mapping based on pitch
        let clampedPitch = max(minPitch, min(maxPitch, note.pitch))
        let pitchRange = maxPitch - minPitch
        let xProgress = CGFloat(clampedPitch - minPitch) / CGFloat(max(pitchRange, 1))
        
        let noteWidth = max(12, width * 0.03)
        let x = width * xProgress
        
        return CGRect(x: x - noteWidth / 2,
                      y: y - noteHeight / 2,
                      width: noteWidth,
                      height: noteHeight)
    }
}
