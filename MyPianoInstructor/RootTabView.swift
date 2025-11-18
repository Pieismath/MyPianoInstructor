//
//  RootTabView.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//
import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var libraryVM: SongLibraryViewModel
    
    @State private var selectedSong: Song? = nil
    @State private var tabSelection: Int = 0

    var body: some View {
        TabView(selection: $tabSelection) {

            NavigationStack {
                SongLibraryView(selectedSong: $selectedSong, tabSelection: $tabSelection)
            }
            .tabItem { Image(systemName: "house") }
            .tag(0)

            NavigationStack {
                ScanMusicView(selectedSong: $selectedSong, tabSelection: $tabSelection)
            }
            .tabItem { Image(systemName: "plus.circle") }
            .tag(1)

            NavigationStack {
                PlaybackView(song: selectedSong)
            }
            .tabItem { Image(systemName: "play.circle") }
            .tag(2)
        }
    }
}
