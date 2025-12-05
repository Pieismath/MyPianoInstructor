//
//  ForceLandscapeOnly.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 12/2/25.
//
import SwiftUI

struct ForceLandscape: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                setLandscape()
            }
            .onDisappear {
                setPortrait()
            }
    }
}

extension View {
    func landscapeOnly() -> some View {
        self.modifier(ForceLandscape())
    }
}

private func setLandscape() {
    AppDelegate.orientationLock = .landscapeRight
    
    DispatchQueue.main.async {
        UIDevice.current.setValue(
            UIInterfaceOrientation.landscapeRight.rawValue,
            forKey: "orientation"
        )
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

private func setPortrait() {
    AppDelegate.orientationLock = .portrait
    
    DispatchQueue.main.async {
        UIDevice.current.setValue(
            UIInterfaceOrientation.portrait.rawValue,
            forKey: "orientation"
        )
        UIViewController.attemptRotationToDeviceOrientation()
    }
}
