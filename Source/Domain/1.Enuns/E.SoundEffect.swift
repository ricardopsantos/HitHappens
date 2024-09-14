//
//  E.SoundEffect.swift
//  Domain
//
//  Created by Ricardo Santos on 23/08/2024.
//

import Foundation

public enum SoundEffect: String, Sendable, CaseIterable, Codable {
    case none
    case airHorn = "air-horn-club.caf"
    case amb1 = "amb1.caf"
    case applause1 = "applause1.caf"
    case applause2 = "applause2.caf"
    case bomb1 = "bomb1.caf"
    case boo1 = "boo1.caf"
    case cheer1 = "cheer1.caf"
    case cheer2 = "cheer2.caf"
    case crickets = "crickets.caf"
    case cuek = "cuek.caf"
    case dixie = "dixie.caf"
    case doh = "doh.caf"
    case drama = "drama.caf"
    case haha = "haha.caf"
    case incorrect = "incorrect.caf"
    case lightSaberOn = "lightsaber_on.caf"
    case rimShot = "rimshot.caf"
    case sadTrombone = "sadtrombone.caf"
}

public extension SoundEffect {
    var localized: String {
        switch self {
        case .none: return "None"
        case .amb1: return "Ambulance"
        case .applause1: return "Clapping"
        case .bomb1: return "Missile"
        case .boo1: return "Boo"
        case .cheer1: return "Cheer 1"
        case .cheer2: return "Cheer 2"
        case .applause2: return "Cheer 3"
        case .cuek: return "Duck"
        case .dixie: return "Horn"
        case .lightSaberOn: return "Lightsaber on"
        case .drama: return "Drama"
        case .incorrect: return "Error"
        case .rimShot: return "Ba dum tss"
        case .sadTrombone: return "Sad Trombone"
        case .airHorn, .crickets, .doh, .haha:
            return rawValue.camelCaseToWords.replace(".Caf", with: "")
        }
    }
}
