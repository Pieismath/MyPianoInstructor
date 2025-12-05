//
//  PianoKeyHelper.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 12/2/25.
//

import Foundation

/// Pure MIDI → piano-key math. No SwiftUI, no main-actor isolation.
struct PianoKeyHelper {

    static let lowestMIDIPitch = 21      // A0
    static let highestMIDIPitch = 108    // C8

    // MARK: - White/Black Key Identification
    static func isWhiteKey(_ midi: Int) -> Bool {
        switch midi % 12 {
        case 0, 2, 4, 5, 7, 9, 11: return true
        default: return false
        }
    }

    static func isBlackKey(_ midi: Int) -> Bool {
        !isWhiteKey(midi)
    }

    // MARK: - Lists of Keys
    static var whiteKeyMIDIs: [Int] {
        (lowestMIDIPitch...highestMIDIPitch).filter { isWhiteKey($0) }
    }

    static var blackKeyMIDIs: [Int] {
        (lowestMIDIPitch...highestMIDIPitch).filter { isBlackKey($0) }
    }

    /// Returns the white key immediately to the left of a black key
    static func whiteIndexBeforeBlack(pitch: Int) -> Int? {
        switch pitch % 12 {
        case 1, 3, 6, 8, 10: return pitch - 1
        default: return nil
        }
    }
}
