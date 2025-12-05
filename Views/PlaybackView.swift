//
//  PlaybackView.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//

import SwiftUI
import Combine

struct PlaybackView: View {

    let playback: PlaybackData

    @Environment(\.dismiss) private var dismiss

    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var scheduler = NoteScheduler()

    private let timer = Timer.publish(every: 0.016, on: .main, in: .common)
        .autoconnect()

    // Time it takes notes to fall from top → keyboard
    private let fallLookahead: TimeInterval = 2.0

    var body: some View {
        VStack(spacing: 10) {

            // 🟦 Back + Title Bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(.trailing, 8)
                }

                Text("Playback")
                    .font(.title2).bold()

                Spacer()
            }
            .padding(.horizontal)

            // 🟦 Falling Notes
            FallingNotesView(
                notes: playback.notes,
                currentTime: currentTime,
                lookahead: fallLookahead
            )
            .frame(height: 125)

            // 🟦 Keyboard View
            PianoKeyboardView(
                highlightedPitches: highlightedPitches()
            )
            .frame(height: 100)

            // 🟦 Scrubber + Time
            VStack(spacing: 6) {
                Slider(
                    value: Binding(
                        get: { currentTime },
                        set: { newValue in seek(to: newValue) }
                    ),
                    in: 0...playback.totalDuration
                )

                Text("\(String(format: "%.2f", currentTime)) / \(String(format: "%.2f", playback.totalDuration))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            // 🟦 Controls
            HStack(spacing: 30) {
                Button(action: togglePlay) {
                    Label(isPlaying ? "Pause" : "Play",
                          systemImage: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)

                Button(action: stop) {
                    Label("Stop", systemImage: "stop.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
            }

            Spacer(minLength: 10)
        }
        .padding(.top, 40)              // ← FIXES CROPPING under Dynamic Island
        .padding(.horizontal)
        .ignoresSafeArea(.keyboard)     // Avoids interfering with safe area
        .onReceive(timer) { _ in
            guard isPlaying else { return }

            currentTime += 0.016

            if currentTime >= playback.totalDuration {
                stop()
            }
        }
    }

    // MARK: - Playback Controls

    private func togglePlay() {
        if isPlaying {
            // Pause playback
            isPlaying = false
            scheduler.pause(at: currentTime)
        } else {
            // Resume
            isPlaying = true
            scheduler.schedule(playback: playback, fromTime: currentTime)
        }
    }

    private func stop() {
        isPlaying = false
        currentTime = 0
        scheduler.cancel()
    }

    // MARK: - Seeking

    private func seek(to time: TimeInterval) {
        currentTime = time
        scheduler.pause(at: time)

        if isPlaying {
            scheduler.schedule(playback: playback, fromTime: time)
        }
    }

    // MARK: - Key Highlight Logic

    private func highlightedPitches() -> Set<Int> {
        var active: Set<Int> = []

        for n in playback.notes {
            if currentTime >= n.startTime &&
               currentTime < n.startTime + n.duration {
                active.insert(n.pitch)
            }
        }

        return active
    }
}
