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
    
    // Parsed playback data for each song id
    @Published var playbackDataBySongID: [UUID: PlaybackData] = [:]

    func addSong(title: String, musicXML: String) -> Song {
        let newSong = Song.mock(title: title, musicXML: musicXML)
        songs.append(newSong)
        return newSong
    }

    var recentSongs: [Song] {
        Array(
            songs.sorted { $0.createdAt > $1.createdAt }
                .prefix(5)
        )
    }
    
    func setPlaybackData(_ data: PlaybackData, for song: Song) {
        playbackDataBySongID[song.id] = data
    }
    
    func playbackData(for song: Song?) -> PlaybackData? {
        guard let song else { return nil }
        return playbackDataBySongID[song.id]
    }
}
