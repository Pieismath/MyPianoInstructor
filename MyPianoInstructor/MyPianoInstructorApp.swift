//
//  MyPianoInstructorApp.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//

import SwiftUI

@main
struct MyPianoInstructorApp: App {
    @StateObject private var libraryVM = SongLibraryViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(libraryVM)
        }
    }
}
