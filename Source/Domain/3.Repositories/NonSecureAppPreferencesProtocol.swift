//
//  NonSecureAppPreferencesProtocol.swift
//  HitHappens
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation
import Combine
//
import Common

public enum NonSecureAppPreferencesOutputActions: Equatable {
    case deletedAll
    case changedKey(key: NonSecureAppPreferencesKey)
}

public enum NonSecureAppPreferencesKey: String, CaseIterable, Equatable {
    case isOnboardingCompleted
    case selectedAppearance
}

public protocol NonSecureAppPreferencesProtocol {
    // MARK: - Properties

    /// The `UserDefaults` instance used for storing non-secure preferences.
    var nonSecureUserDefaults: UserDefaults { get }

    /// A Boolean value indicating whether the onboarding process is completed.
    var isOnboardingCompleted: Bool { get set }

    /// The selected appearance theme.
    var selectedAppearance: String? { get set }

    // MARK: - Utilities

    /// Emits actions related to non-secure app preferences, allowing listeners to react to changes.
    /// - Parameter filter: An array of actions to filter the output stream.
    /// - Returns: A publisher emitting non-secure app preferences actions.
    func output(_ filter: [NonSecureAppPreferencesOutputActions]) -> AnyPublisher<NonSecureAppPreferencesOutputActions, Never>

    // MARK: - Methods

    /// Deletes all non-secure app preferences.
    func deleteAll()
}
