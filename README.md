# MyPianoInstructor

MyPianoInstructor is an interactive piano-learning app built with SwiftUI.  
Users can scan sheet music, automatically generate a playable transcription, and learn pieces through a real-time piano keyboard visualization.

This project aims to make reading complex sheet music easier for beginners and intermediate players by providing a “Synthesia-style” playback experience directly on iOS.

---

## 🚀 Features (In Progress)

### ✔️ App Architecture (MVVM)
- `Song` model for metadata  
- `SongLibraryViewModel` with `@Published` song storage  
- EnvironmentObject state shared across all screens  

### ✔️ Tab-Based Navigation
A clean `TabView` with:
- **Home** – full song library
- **Scan** – upload or capture sheet music (mock flow)
- **Play** – playback UI using selected or newly scanned song

### ✔️ Song Library UI
- Displays all songs created by the user  
- Shows recently scanned songs  
- Tapping a song loads it directly into PlaybackView  

### ✔️ Sheet Music Scanning (Mocked)
- UI for uploading or photographing sheet music  
- Input prompt for song title  
- Adds new song to library and jumps to playback  

### ✔️ Playback Screen
Includes:
- Selected song title  
- Mock sheet music preview  
- Play / Pause / Jump buttons  
- Progress bar  
- Animated piano keyboard that highlights keys over time  

### ✔️ Piano Keyboard Component
Reusable `PianoKeyboardView` that:
- Draws a horizontal keyboard  
- Highlights one key at a time based on playback animation  
- Built with GeometryReader + variable key sizing  

---

## 🎯 Current Architecture
MyPianoInstructor/
│
├── MyPianoInstructorApp.swift       // EnvironmentObject setup
├── RootTabView.swift                // Bottom navigation
│
├── Models/
│   └── Song.swift
│
├── ViewModels/
│   └── SongLibraryViewModel.swift
│
└── Views/
├── SongLibraryView.swift
├── ScanMusicView.swift
├── PlaybackView.swift
└── PianoKeyboardView.swift
---

## 🔧 Tech Stack

- **SwiftUI**
- **MVVM Architecture**
- **ObservableObject + EnvironmentObject**
- **Timer-based animations**
- **(Future) AVAudioEngine for MIDI playback**
- **(Future) OMR (Optical Music Recognition) API for sheet music parsing**

---

## 🛣️ Roadmap

### Short-Term
- Add realistic black/white keys to the keyboard  
- Add basic audio playback for each highlighted note  
- Add real persistence (SwiftData or CoreData)  
- Improve UI layout and spacing  

### Medium-Term
- Integrate real OMR (Optical Music Recognition)  
- Parse MusicXML into a playable timeline  
- Display falling-note animation instead of simple highlights  

### Long-Term
- Export videos of playback  
- Allow custom tempo and looping  
- Cloud sync for scanned songs  
- Learn-mode with slowing, pausing, and note isolation  

---

## 📸 Screenshots / Wireframes

(Soon: add your hand-drawn sketches or simulator screenshots)

---

## 🤝 Contributing

Pull requests are welcome as the project evolves.  
For major changes, please open an issue first to discuss what you’d like to change.

---

## 📜 License

This project is open-source under the MIT license.
