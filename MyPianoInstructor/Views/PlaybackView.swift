//
//  PlaybackView.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//

import SwiftUI

struct PlaybackView: View {
    @EnvironmentObject var libraryVM: SongLibraryViewModel
    
    let song: Song?
    
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    
    // How many seconds ahead the notes should appear above the keyboard
    let lookahead: TimeInterval = 3.0
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Playback")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            .padding(.top)
            
            if let song,
               let playback = libraryVM.playbackData(for: song) {
                
                Text(song.title)
                    .font(.headline)
                
                // Fake sheet music block
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 1)
                    .frame(height: 140)
                    .overlay(
                        Text("Sheet music / measure view")
                            .foregroundColor(.secondary)
                    )
                
                // Controls
                HStack(spacing: 40) {
                    Button {
                        currentTime = 0
                    } label: {
                        Image(systemName: "backward.end.fill")
                    }
                    .font(.title2)
                    
                    Button {
                        togglePlay(totalDuration: playback.totalDuration)
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    }
                    .font(.largeTitle)
                    
                    Button {
                        stepForward(totalDuration: playback.totalDuration)
                    } label: {
                        Image(systemName: "forward.end.fill")
                    }
                    .font(.title2)
                }
                .padding(.top, 8)
                
                // Progress bar over entire song duration
                ProgressView(value: currentTime, total: playback.totalDuration)
                    .padding(.horizontal)
                
                // Falling notes + keyboard
                VStack(spacing: 8) {
                    FallingNotesView(
                        notes: playback.notes,
                        currentTime: currentTime,
                        lookahead: lookahead
                    )
                    .frame(height: 160)
                    
                    PianoKeyboardView(
                        highlightedIndex: highlightedKeyIndex(from: playback.notes)
                    )
                    .frame(height: 120)
                }
                .padding(.top, 8)
                
                Spacer()
            } else {
                Spacer()
                Text("Select or scan a song to start playback.")
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal)
        .onDisappear {
            isPlaying = false
        }
    }
    
    // Map "current notes" to a key index, just as a demo
    private func highlightedKeyIndex(from notes: [NoteEvent]) -> Int {
        // Take the first note that is currently sounding
        if let active = notes.first(where: { note in
            currentTime >= note.startTime &&
            currentTime <= note.startTime + note.duration
        }) {
            // compress pitch to a small keyboard index
            let basePitch = 60 // middle C
            let offset = max(0, min(13, active.pitch - basePitch))
            return offset
        }
        return 0
    }
    
    private func togglePlay(totalDuration: TimeInterval) {
        isPlaying.toggle()
        if isPlaying {
            startTimer(totalDuration: totalDuration)
        }
    }
    
    private func startTimer(totalDuration: TimeInterval) {
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if !isPlaying {
                timer.invalidate()
                return
            }
            currentTime += 0.03
            if currentTime >= totalDuration {
                currentTime = totalDuration
                isPlaying = false
                timer.invalidate()
            }
        }
    }
    
    private func stepForward(totalDuration: TimeInterval) {
        currentTime += 0.25
        if currentTime > totalDuration {
            currentTime = totalDuration
        }
    }
}

