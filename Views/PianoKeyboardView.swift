//
//  PianoKeyboardView.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//

import SwiftUI

struct PianoKeyboardView: View {
    let highlightedPitches: Set<Int>

    private let whiteKeys = PianoKeyHelper.whiteKeyMIDIs

    var body: some View {
        GeometryReader { geo in
            let whiteWidth = geo.size.width / CGFloat(whiteKeys.count)

            ZStack(alignment: .topLeading) {

                // WHITE KEYS
                HStack(spacing: 0) {
                    ForEach(whiteKeys, id: \.self) { pitch in
                        Rectangle()
                            .fill(highlightedPitches.contains(pitch) ? Color.blue.opacity(0.4) : .white)
                            .overlay(Rectangle().stroke(.black, lineWidth: 1))
                    }
                }

                // BLACK KEYS
                HStack(spacing: 0) {
                    ForEach(whiteKeys.indices, id: \.self) { i in
                        let wPitch = whiteKeys[i]
                        let next = (i + 1 < whiteKeys.count) ? whiteKeys[i+1] : nil

                        ZStack {
                            if let up = next,
                               PianoKeyHelper.hasBlackKey(between: wPitch, and: up) {

                                let blackPitch = wPitch + 1

                                Rectangle()
                                    .fill(highlightedPitches.contains(blackPitch)
                                          ? Color.blue.opacity(0.8)
                                          : .black)
                                    .frame(width: whiteWidth * 0.65,
                                           height: geo.size.height * 0.6)
                                    .offset(x: whiteWidth * 0.75)
                            }
                        }
                        .frame(width: whiteWidth)
                    }
                }
            }
        }
        .clipped()
    }
}


// MARK: - KEY POSITION MAP (shared with FallingNotesView)

extension PianoKeyboardView {
    static func keyPositions(in size: CGSize) -> [Int: CGFloat] {

        let whiteKeys = PianoKeyHelper.whiteKeyMIDIs
        let whiteWidth = size.width / CGFloat(whiteKeys.count)

        var map: [Int : CGFloat] = [:]

        // White keys
        for (i, pitch) in whiteKeys.enumerated() {
            map[pitch] = CGFloat(i) * whiteWidth + whiteWidth / 2
        }

        // Black keys — exactly the same geometry as the keyboard above
        for i in whiteKeys.indices {
            let wPitch = whiteKeys[i]
            let nextPitch = (i + 1 < whiteKeys.count) ? whiteKeys[i + 1] : nil

            if let next = nextPitch,
               PianoKeyHelper.hasBlackKey(between: wPitch, and: next) {

                let blackPitch = wPitch + 1
                let x = CGFloat(i) * whiteWidth + whiteWidth * 0.75
                map[blackPitch] = x
            }
        }

        return map
    }
}
