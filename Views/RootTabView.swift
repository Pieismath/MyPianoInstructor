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

            // HOME TAB
            NavigationStack {
                SongLibraryView(selectedSong: $selectedSong, tabSelection: $tabSelection)
                    .environmentObject(libraryVM)
            }
            .tabItem { Image(systemName: "house") }
            .tag(0)

            // SCAN TAB
            NavigationStack {
                ScanMusicView(selectedSong: $selectedSong, tabSelection: $tabSelection)
                    .environmentObject(libraryVM)
            }
            .tabItem { Image(systemName: "plus.circle") }
            .tag(1)

            // PLAY TAB
            NavigationStack {
                if let selectedSong,
                   let xmlData = selectedSong.musicXML.data(using: .utf8) {

                    let playback = MusicXMLParser.parse(data: xmlData)

                    PlaybackView(playback: playback)
                        .environmentObject(libraryVM)

                } else {
                    Text("No song selected")
                }
            }
            .landscapeOnly()
            .toolbar(.hidden, for: .tabBar)
            .tabItem { Image(systemName: "play.circle") }
            .tag(2)
        }

        // Handle tab switching notifications
        .onReceive(NotificationCenter.default.publisher(for: .switchTab)) { notif in
            if let index = notif.object as? Int {
                tabSelection = index
            }
        }
    }
}
