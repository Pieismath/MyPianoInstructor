//
//  AudioEngineManager.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 12/2/25.
//

import Foundation
import AVFoundation

class AudioEngineManager {
    static let shared = AudioEngineManager()

    private let engine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler()

    private var _isReady = false
    private let readyLock = NSLock()
    private var isReady: Bool {
        get { readyLock.lock(); defer { readyLock.unlock() }; return _isReady }
        set { readyLock.lock(); _isReady = newValue; readyLock.unlock() }
    }
    private(set) var loadError: String?

    private init() {
        setupAudio()
    }
    
    private func setupAudio() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)

        do {
            engine.prepare()
            try engine.start()
            print("Audio engine started.")
        } catch {
            loadError = "Audio engine failed to start: \(error.localizedDescription)"
            print("Audio engine failed to start:", error)
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.loadPiano()
        }
    }

    private func loadPiano() {
        guard let url = Bundle.main.url(forResource: "Piano", withExtension: "sf2") else {
            let msg = "Piano.sf2 is missing from the app bundle. Add it to the Xcode target's 'Copy Bundle Resources' phase."
            print("[AudioEngineManager] \(msg)")
            // Write loadError and post notification on the main thread to avoid data races.
            DispatchQueue.main.async { [weak self] in
                self?.loadError = msg
                NotificationCenter.default.post(name: .audioEngineLoadFailed, object: msg)
            }
            return
        }

        do {
            try sampler.loadSoundBankInstrument(
                at: url,
                program: 0,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: 0
            )
            self.isReady = true
            print("Loaded Piano.sf2 successfully.")

            // Prime buffers
            self.play(note: 60, velocity: 0)

        } catch {
            let msg = "Failed to load piano sounds: \(error.localizedDescription)"
            print("Failed to load SoundFont:", error)
            DispatchQueue.main.async { [weak self] in
                self?.loadError = msg
            }
        }
    }

    func play(note: Int, velocity: UInt8 = 100) {
        if isReady {
            sampler.startNote(UInt8(note), withVelocity: velocity, onChannel: 0)
        }
    }

    func stop(note: Int) {
        if isReady {
            sampler.stopNote(UInt8(note), onChannel: 0)
        }
    }
    
    /// Immediately silence all active notes.
    func stopAll() {
        guard isReady else { return }
        // CC 120 = All Sound Off (Instantly cuts the reverb/release tails)
        sampler.sendController(120, withValue: 0, onChannel: 0)
        // CC 123 = All Notes Off (Ensures keys are technically lifted)
        sampler.sendController(123, withValue: 0, onChannel: 0)
    }
}
