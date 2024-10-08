//
//  AppScreen.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Common
import Domain

public enum AppScreen: Hashable, Identifiable, Sendable {
    case na
    // Generic
    case splash
    case root
    case mainApp // TabBar
    // HitHappens app
    case onboarding(model: OnboardingModel)
    case settings
    case calendar
    case map
    case favoriteEvents
    case eventsList
    case eventDetails(model: EventDetailsModel?)
    case eventLogDetails(model: EventLogDetailsModel)
    case webView(model: WebViewModel)
    //
    case templateWith(model: ___Template___Model)
    // Template App
    public var id: String {
        String(describing: self)
    }
}
