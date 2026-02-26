//
//  MIDIInputManager.swift
//  MyPianoInstructor
//
//  Created by Jason Fang on 2/15/26.
//

import Foundation
import CoreMIDI
import Observation

@Observable
class MIDIInputManager {

    var pressedKeys: Set<Int> = []
    var isConnected: Bool = false
    var deviceName: String = ""

    private var midiClient: MIDIClientRef = 0
    private var inputPort: MIDIPortRef = 0

    init() {
        setupMIDI()
    }

    deinit {
        if inputPort != 0 { MIDIPortDispose(inputPort) }
        if midiClient != 0 { MIDIClientDispose(midiClient) }
    }

    // MARK: - Setup

    private func setupMIDI() {
        let clientStatus = MIDIClientCreateWithBlock("MyPianoInstructor" as CFString, &midiClient) { [weak self] notification in
            self?.handleMIDINotification(notification)
        }
        guard clientStatus == noErr else {
            print("MIDI client creation failed: \(clientStatus)")
            return
        }

        let portStatus = MIDIInputPortCreateWithProtocol(
            midiClient,
            "Input" as CFString,
            ._1_0,
            &inputPort
        ) { [weak self] eventList, _ in
            self?.handleMIDIEventList(eventList)
        }
        guard portStatus == noErr else {
            print("MIDI input port creation failed: \(portStatus)")
            return
        }

        connectSources()
    }

    // MARK: - Source Connection

    private func connectSources() {
        let sourceCount = MIDIGetNumberOfSources()
        guard sourceCount > 0 else {
            DispatchQueue.main.async {
                self.isConnected = false
                self.deviceName = ""
            }
            return
        }

        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)
            MIDIPortConnectSource(inputPort, source, nil)
        }

        // Get name of first source
        let firstSource = MIDIGetSource(0)
        var name: Unmanaged<CFString>?
        MIDIObjectGetStringProperty(firstSource, kMIDIPropertyDisplayName, &name)
        let sourceName = (name?.takeRetainedValue() as String?) ?? "MIDI Device"

        DispatchQueue.main.async {
            self.isConnected = true
            self.deviceName = sourceName
        }
    }

    // MARK: - Notification Handling

    private func handleMIDINotification(_ notification: UnsafePointer<MIDINotification>) {
        switch notification.pointee.messageID {
        case .msgSetupChanged:
            // A device was connected or disconnected — reconnect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.connectSources()
            }
        default:
            break
        }
    }

    // MARK: - MIDI Event Parsing

    private func handleMIDIEventList(_ eventListPtr: UnsafePointer<MIDIEventList>) {
        let eventList = eventListPtr.pointee

        // Walk the event list packets
        withUnsafePointer(to: eventList.packet) { firstPacket in
            var packet = firstPacket
            for _ in 0..<eventList.numPackets {
                let p = packet.pointee
                parseUniversalPacket(p)
                packet = UnsafePointer(MIDIEventPacketNext(packet))
            }
        }
    }

    private func parseUniversalPacket(_ packet: MIDIEventPacket) {
        // MIDIEventPacket stores words; for MIDI 1.0 protocol the first word
        // encodes channel voice messages in the Universal MIDI Packet format.
        // Require at least 1 word and validate MIDI note/velocity ranges.
        guard packet.wordCount >= 1 else { return }

        let word = packet.words.0
        // UMP MIDI 1.0 channel voice: top nibble of the first byte = message type 0x2
        let messageType = (word >> 28) & 0xF

        guard messageType == 0x2 else { return } // MIDI 1.0 Channel Voice

        let status = (word >> 20) & 0xF
        let note = Int((word >> 8) & 0x7F)
        let velocity = Int(word & 0x7F)

        // Validate MIDI note is in the standard 0-127 range
        guard note >= 0 && note <= 127 else { return }

        switch status {
        case 0x9: // Note On
            if velocity > 0 {
                DispatchQueue.main.async {
                    AudioEngineManager.shared.play(note: note, velocity: UInt8(velocity))
                    self.pressedKeys.insert(note)
                }
            } else {
                // Note-on with velocity 0 = note-off
                DispatchQueue.main.async {
                    AudioEngineManager.shared.stop(note: note)
                    self.pressedKeys.remove(note)
                }
            }

        case 0x8: // Note Off
            DispatchQueue.main.async {
                AudioEngineManager.shared.stop(note: note)
                self.pressedKeys.remove(note)
            }

        default:
            break
        }
    }
}
