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
    func play() {
        let soundPlayer = SoundPlayer()
        soundPlayer.configureAudioSession()
        soundPlayer.playSound(self)
    }

    class SoundPlayer {
        static var audioPlayer: AVAudioPlayer?
        func configureAudioSession() {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                DevTools.Log.error("Failed to set audio session category: \(error)", .generic)
            }
        }

        func playSound(_ sound: SoundEffect) {
            guard sound != .none else { return }
            guard let soundURL = Bundle.main.url(forResource: sound.rawValue, withExtension: nil) else {
                DevTools.Log.error("Sound file not found: \(sound.rawValue)", .generic)
                return
            }
            do {
                SoundPlayer.audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                SoundPlayer.audioPlayer?.play()
            } catch {
                DevTools.Log.error(error, .generic)
            }
        }
    }
}
