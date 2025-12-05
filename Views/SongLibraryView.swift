//
//  SongLibraryView.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//
import SwiftUI

struct SongLibraryView: View {
    @EnvironmentObject var libraryVM: SongLibraryViewModel
    
    @Binding var selectedSong: Song?
    @Binding var tabSelection: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("MyPianoInstructor")
                .font(.headline)
                .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // “Your Songs” section
                    Text("Your Songs")
                        .font(.title2)
                        .bold()
                    
                    if libraryVM.songs.isEmpty {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .frame(height: 120)
                            .overlay(
                                Text("No songs yet.\nTap Scan to add one.")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 120)
                            .overlay(
                                VStack(alignment: .leading) {
                                    ForEach(libraryVM.songs.prefix(3)) { song in
                                        Button {
                                            select(song)
                                        } label: {
                                            Text("• \(song.title)")
                                                .foregroundColor(.primary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                                .padding()
                            )
                    }
                    
                    // “Recent Songs” list
                    if !libraryVM.recentSongs.isEmpty {
                        Text("Recent Songs")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        ForEach(libraryVM.recentSongs) { song in
                            Button {
                                select(song)
                            } label: {
                                HStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay(Image(systemName: "music.note"))
                                    
                                    VStack(alignment: .leading) {
                                        Text(song.title)
                                            .font(.subheadline)
                                        Text(song.createdAt, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    
                                    Text(formatDuration(song.durationSeconds))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func select(_ song: Song) {
        selectedSong = song
        tabSelection = 2  // jump to Playback tab
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
