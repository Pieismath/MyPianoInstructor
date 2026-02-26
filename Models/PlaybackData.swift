//
//  PlaybackData.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/20/25.
//

import Foundation

// Pedal Info (Audio Only)
// Stored separately so we don't stretch the visual notes.
struct PedalEvent: Codable, Hashable {
    let startTime: TimeInterval
    let isDown: Bool
}

/// All the timing + pitch info needed for playback & visualization
struct PlaybackData: Codable, Hashable {
    /// Tempo in beats per minute
    let tempo: Double

    /// Total length of the piece in seconds
    let totalDuration: TimeInterval

    /// The sequence of notes in this song
    let notes: [NoteEvent]
    
    /// The sequence of pedal events (default empty for backwards compatibility)
    var pedalEvents: [PedalEvent] = []
}
