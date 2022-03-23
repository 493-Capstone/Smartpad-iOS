//
//  HapticManager.swift
//  Smartpad-iOS
//
//  Created by Alireza Azimi on 2022-03-08.
//
import Foundation
import CoreHaptics

class HapticManager {
  let hapticEngine: CHHapticEngine

  init?() {
    let hapticCapability = CHHapticEngine.capabilitiesForHardware()
    guard hapticCapability.supportsHaptics else {
      return nil
    }

    do {
      hapticEngine = try CHHapticEngine()
    } catch let error {
      print("Haptic engine Creation Error: \(error)")
      return nil
    }
  }
}

extension HapticManager {
    private func touchDownPattern() throws -> CHHapticPattern {
        let snip = CHHapticEvent(
          eventType: .hapticTransient,
          parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
          ],
          relativeTime: 0.08)

        return try CHHapticPattern(events: [snip], parameters: [])
    }
    
    private func touchReleasePattern() throws -> CHHapticPattern {
        let snip = CHHapticEvent(
          eventType: .hapticTransient,
          parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
          ],
          relativeTime: 0.02)

        return try CHHapticPattern(events: [snip], parameters: [])
    }
    
    func playTouchDown() {
        do {
            let pattern = try touchDownPattern()
            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticEngine.notifyWhenPlayersFinished { _ in
              return .stopEngine
            }
        } catch {
            print("Failed to play slice: \(error)")
        }
    }
    
    func playTouchRelease() {
        do {
            let pattern = try touchReleasePattern()
            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticEngine.notifyWhenPlayersFinished { _ in
              return .stopEngine
            }
        } catch {
            print("Failed to play slice: \(error)")
        }
    }
}
