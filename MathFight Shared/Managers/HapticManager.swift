//
//  HapticManager.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import Foundation
import CoreHaptics

class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    private var supportedHapptics = false
    
    private init() {
        checkSupportsHaptics()
        setupHapticEngine()
    }
    
    func checkSupportsHaptics() {
        // Check if the device supports haptics.
        supportedHapptics =
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard supportedHapptics else { return }
    }
    
    func setupHapticEngine() {
        // Create and configure a haptic engine.
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch let error {
            print("Engine Creation Error: \(error)")
        }
    }
    
    func playHaptic(duration: Double = 0.05, intensity: Float = 1.0) {
        guard supportedHapptics, let engine = engine else { return }
        
        let intensity = CHHapticEventParameter(
            parameterID: .hapticIntensity, value: intensity)
        let sharpness = CHHapticEventParameter(
            parameterID: .hapticSharpness, value: 1.0)
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous, parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: duration
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Error playing haptic: \(error)")
        }
    }
}
