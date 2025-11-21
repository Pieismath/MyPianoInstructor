//
//  PlaybackData.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/20/25.
//

import Foundation

struct PlaybackData {
    let tempo: Double                 // beats per minute
    let totalDuration: TimeInterval   // seconds
    let notes: [NoteEvent]
}
