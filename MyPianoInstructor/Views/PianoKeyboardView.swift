//
//  PianoKeyboardView.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 11/17/25.
//
import SwiftUI

struct PianoKeyboardView: View {
    let highlightedIndex: Int
    let totalKeys: Int = 14
    
    var body: some View {
        GeometryReader { geo in
            let keyWidth = geo.size.width / CGFloat(totalKeys)
            
            HStack(spacing: 0) {
                ForEach(0..<totalKeys, id: \.self) { index in
                    Rectangle()
                        .fill(index == highlightedIndex ? Color.blue.opacity(0.6) : Color.white)
                        .border(Color.black, width: 1)
                        .frame(width: keyWidth)
                }
            }
        }
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
