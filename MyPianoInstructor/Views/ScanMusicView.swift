//
//  ScanMusicView.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//
import SwiftUI

struct ScanMusicView: View {
    @EnvironmentObject var libraryVM: SongLibraryViewModel
    
    @Binding var selectedSong: Song?
    @Binding var tabSelection: Int
    
    @State private var songTitle: String = ""
    @State private var inputType: InputType = .camera
    @State private var isScanning: Bool = false
    @State private var statusText: String = "Ready to upload..."
    
    enum InputType: String, CaseIterable, Identifiable {
        case camera = "Camera"
        case pdf = "PDF"
        var id: String { rawValue }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Button {
                    tabSelection = 0
                } label: {
                    Image(systemName: "chevron.left")
                }
                Text("Scan Sheet Music")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            .padding(.top)
            
            // Placeholder for camera / PDF preview
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(height: 160)
                .overlay(
                    Text("Sheet music preview\n(Camera / PDF here)")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                )
            
            // Input type selector
            Picker("Input", selection: $inputType) {
                ForEach(InputType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            // Song title field
            VStack(alignment: .leading, spacing: 8) {
                Text("Song title")
                    .font(.subheadline)
                TextField("Enter song title", text: $songTitle)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button {
                simulateScan()
            } label: {
                HStack {
                    if isScanning {
                        ProgressView()
                    }
                    Text(isScanning ? "Processing..." : "Scan / Upload")
                        .bold()
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(songTitle.trimmingCharacters(in: .whitespaces).isEmpty || isScanning)
            
            Text(statusText)
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private func simulateScan() {
        isScanning = true
        statusText = "Uploading and analyzing sheet music..."
        
        // Simulate network delay + OMR processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let newSong = libraryVM.addSong(title: songTitle)
            selectedSong = newSong
            statusText = "Created playback for \(newSong.title)."
            isScanning = false
            tabSelection = 2       // jump to Playback tab
        }
    }
}
