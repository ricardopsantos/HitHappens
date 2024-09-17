//
//  SoundEffect.swift
//  Domain
//
//  Created by Ricardo Santos on 23/08/2024.
//

import Foundation
import AVFAudio
//
import DevTools
import Domain

public extension SoundEffect {
    static func with(localized: String) -> SoundEffect? {
        SoundEffect.allCases.first { $0.localized == localized }
    }

    func play() {
        SoundPlayer.shared.playSound(self)
    }

    class SoundPlayer: NSObject, AVAudioPlayerDelegate {
        static let shared = SoundPlayer()
        private var audioPlayer: AVAudioPlayer?
        private var audioSession: AVAudioSession?

        override private init() {
            super.init()
        }

        func playSound(_ sound: SoundEffect) {
            if audioPlayer != nil {
                stopSound()
            }
            guard audioPlayer == nil, audioSession == nil else { return }
            guard sound != .none else { return }
            guard let soundURL = Bundle.main.url(forResource: sound.rawValue, withExtension: nil) else {
                DevTools.Log.error("Sound file not found: \(sound.rawValue)", .generic)
                return
            }

            do {
                activateAudioSession() // Ensure session is configured before playback
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.delegate = self
                audioPlayer?.play()
            } catch {
                DevTools.Log.error("Failed to play sound: \(error)", .generic)
                deactivateAudioSession() // Clean up if playback fails
            }
        }

        func stopSound() {
            audioPlayer?.stop()
            deactivateAudioSession() // Deactivate session when sound is stopped
        }

        public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            deactivateAudioSession()
        }

        private func activateAudioSession() {
            guard audioSession == nil else { return } // Avoid re-activation
            do {
                audioSession = AVAudioSession.sharedInstance()
                try audioSession?.setCategory(.playback, mode: .default, options: [])
                try audioSession?.setActive(true)
            } catch {
                DevTools.Log.error("Failed to set audio session category: \(error)", .generic)
            }
        }

        private func deactivateAudioSession() {
            defer {
                audioSession = nil
                audioPlayer = nil
            }
            do {
                try audioSession?.setActive(false)
            } catch {
                DevTools.Log.error("Failed to deactivate audio session: \(error)", .generic)
            }
        }
    }
}
