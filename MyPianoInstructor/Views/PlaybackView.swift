//
//  PlaybackView.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//

import SwiftUI

struct PlaybackView: View {
    let song: Song?
    
    @State private var isPlaying = false
    @State private var currentBeat: Int = 0
    let totalBeats = 16          // just for the mock animation
    let totalKeys = 14           // small piano
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Playback")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            .padding(.top)
            
            if let song {
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
                        currentBeat = 0
                    } label: {
                        Image(systemName: "backward.end.fill")
                    }
                    .font(.title2)
                    
                    Button {
                        togglePlay()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    }
                    .font(.largeTitle)
                    
                    Button {
                        stepForward()
                    } label: {
                        Image(systemName: "forward.end.fill")
                    }
                    .font(.title2)
                }
                .padding(.top, 8)
                
                // Simple horizontal progress line
                ProgressView(value: Double(currentBeat), total: Double(totalBeats))
                    .padding(.horizontal)
                
                // Piano keyboard
                PianoKeyboardView(highlightedIndex: highlightedKeyIndex)
                    .frame(height: 120)
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
    
    private var highlightedKeyIndex: Int {
        // Map beats to key indexes just to show something moving.
        guard totalBeats > 0 else { return 0 }
        return (currentBeat * totalKeys / max(totalBeats, 1)) % totalKeys
    }
    
    private func togglePlay() {
        isPlaying.toggle()
        
        if isPlaying {
            startTimer()
        }
    }
    
    private func startTimer() {
        // super simple “animation” using a repeating timer
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if !isPlaying {
                timer.invalidate()
                return
            }
            currentBeat = (currentBeat + 1) % (totalBeats + 1)
        }
    }
    
    private func stepForward() {
        currentBeat = (currentBeat + 1) % (totalBeats + 1)
    }
}

