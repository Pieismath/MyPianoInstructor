//
//  Note.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/20/25.
//

import Foundation

/// A single logical note event in the song
struct NoteEvent: Identifiable, Codable, Hashable {
    var id: UUID = UUID()        // <— now Codable can overwrite it

    let pitch: Int
    let startTime: TimeInterval
    let duration: TimeInterval
}
