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

    private init() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)

        do {
            try engine.start()
            print("Audio engine started.")
        } catch {
            print("❌ Audio engine failed to start:", error)
        }

        loadPiano()
    }

    private func loadPiano() {
        guard let url = Bundle.main.url(forResource: "Piano", withExtension: "sf2") else {
            print("❌ Could not find Piano.sf2 in bundle!")
            return
        }

        do {
            try sampler.loadSoundBankInstrument(
                at: url,
                program: 0,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: 0
            )
            print("🎹 Loaded Piano.sf2 successfully.")
        } catch {
            print("❌ Failed to load SoundFont:", error)
        }
    }

    func play(note: Int) {
        sampler.startNote(UInt8(note), withVelocity: 100, onChannel: 0)
    }

    func stop(note: Int) {
        sampler.stopNote(UInt8(note), onChannel: 0)
    }
}
