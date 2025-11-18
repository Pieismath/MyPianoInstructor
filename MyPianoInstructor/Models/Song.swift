//
//  Song.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//
import Foundation

struct Song: Identifiable, Equatable {
    let id: UUID
    var title: String
    var createdAt: Date
    var durationSeconds: Int
    
    static func mock(title: String) -> Song {
        Song(id: UUID(),
             title: title,
             createdAt: Date(),
             durationSeconds: Int.random(in: 60...360))
    }
}
