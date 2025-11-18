//
//  SongLibraryViewModel.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//
import Foundation
import Combine

class SongLibraryViewModel: ObservableObject {
    @Published var songs: [Song] = []

    func addSong(title: String) -> Song {
        let newSong = Song.mock(title: title)
        songs.append(newSong)
        return newSong
    }

    var recentSongs: [Song] {
        Array(
            songs.sorted { $0.createdAt > $1.createdAt }
                .prefix(5)
        )
    }
}
