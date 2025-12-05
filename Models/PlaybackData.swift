//
//  PlaybackData.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/20/25.
//


import Foundation

/// All the timing + pitch info needed for playback & visualization
struct PlaybackData: Codable, Hashable {
    /// Tempo in beats per minute (optional for now, but useful later)
    let tempo: Double

    /// Total length of the piece in seconds
    let totalDuration: TimeInterval

    /// The sequence of notes in this song
    let notes: [NoteEvent]
}
