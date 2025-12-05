//
//  ScanMusicView.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//
//
//  ScanMusicView.swift
//  MyPianoInstructor
//

import SwiftUI
import UniformTypeIdentifiers

struct ScanMusicView: View {
    @EnvironmentObject var libraryVM: SongLibraryViewModel
    
    @Binding var selectedSong: Song?
    @Binding var tabSelection: Int
    
    @State private var songTitle: String = ""
    @State private var isImporting = false
    @State private var statusText: String = "Upload a MusicXML file."
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // BACK BUTTON + TITLE
            HStack {
                Button {
                    tabSelection = 0
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                
                Text("Import MusicXML")
                    .font(.title2)
                    .bold()
                
                Spacer()
            }
            .padding(.top)
            
            
            // Song Title
            VStack(alignment: .leading, spacing: 8) {
                Text("Song title")
                    .font(.subheadline)
                TextField("Enter song title", text: $songTitle)
                    .textFieldStyle(.roundedBorder)
            }
            
            
            // IMPORT BUTTON
            Button {
                isImporting = true
            } label: {
                Text("Select MusicXML File")
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(songTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            
            
            // Status
            Text(statusText)
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.xml, .musicXML, .compressedMusicXML],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
    }
    
    
    // MARK: - FILE IMPORT HANDLER
    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            statusText = "Import failed: \(error.localizedDescription)"
            
        case .success(let urls):
            guard let url = urls.first else {
                statusText = "No file selected."
                return
            }
            
            do {
                let data = try Data(contentsOf: url)

                // ⬇️ REAL PARSER NOW
                let xmlString = String(decoding: data, as: UTF8.self)

                // Create Song INCLUDING its MusicXML
                let newSong = libraryVM.addSong(
                    title: songTitle,
                    musicXML: xmlString
                )

                selectedSong = newSong
                statusText = "Imported successfully!"
                tabSelection = 2
            } catch {
                statusText = "Failed to read file."
            }
        }
    }
}


// MARK: - File Types Extension
import UniformTypeIdentifiers

extension UTType {

    /// Uncompressed MusicXML (.musicxml or .xml)
    static var musicXML: UTType {
        UTType(filenameExtension: "musicxml")!
    }

    /// Compressed MusicXML (.mxl)
    static var compressedMusicXML: UTType {
        UTType(filenameExtension: "mxl")!
    }
}
