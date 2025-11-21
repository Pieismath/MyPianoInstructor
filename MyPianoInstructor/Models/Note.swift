//
//  Note.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/20/25.
//

import Foundation

struct NoteEvent: Identifiable {
    let id = UUID()
    
    // Very simplified for now
    let pitch: Int          // e.g. MIDI note number 21–108
    let startTime: TimeInterval   // seconds from song start
    let duration: TimeInterval    // seconds long
}
