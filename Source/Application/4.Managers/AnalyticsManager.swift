//
//  AnalyticsManager.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
#if FIREBASE_ENABLED
import FirebaseAnalytics
import Firebase
#endif
//
import DevTools
import SwiftUI

extension AnalyticsManager {
    enum EventType {
        // Bussines Events
        case login
        case updateUser
        // Generic Events
        case appLifeCycleEvent(label: String)
        case buttonClick(type: ButtonType, label: String)
        case listItemTap(label: String)

        enum ButtonType: String {
            case primary = "Primary"
            case secondary = "Secondary"
            case text = "Text"
            case back = "Back"
            case navigationTab = "Navigation Tab"
        }

        var rawValue: String {
            switch self {
            case .buttonClick(type: let type, label: let label):
                return "buttonClick_\(type)_\(label)"
            case .listItemTap(label: let label):
                return "listItemTap_\(label)"
            case .appLifeCycleEvent(label: let label):
                return "appLifeCycleEvent_\(label)"
            default:
                return "\(self)"
            }
        }

        /// Firebase event names must be alphanumeric/underscore, max 40 chars —
        /// labels with spaces (e.g. "Save Tracker") would be rejected otherwise.
        var firebaseEventName: String {
            String(rawValue.map { $0.isLetter || $0.isNumber ? $0 : "_" }.prefix(40))
        }
    }
}

class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    func handleScreenIn(appScreen: AppScreen) {
        guard FirebaseApp.configIsValidAndAvailable else {
            return
        }
        #if FIREBASE_ENABLED
        let parameters: [String: Any] = [
            AnalyticsParameterScreenName: appScreen.id.description
        ]
        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
        #endif
    }

    func handleCustomEvent(
        eventType: EventType,
        properties: [String: Any] = [:],
        sender: String
    ) {
        handle(eventType: eventType, properties: properties, label: nil, sender: sender)
    }

    func handleAppLifeCycleEvent(
        label: String,
        sender: String,
        properties: [String: Any] = [:]
    ) {
        handle(eventType: .appLifeCycleEvent(label: label), properties: properties, label: label, sender: sender)
    }

    func handleListItemTapEvent(
        label: String,
        sender: String,
        properties: [String: Any] = [:]
    ) {
        handle(eventType: .listItemTap(label: label), properties: properties, label: label, sender: sender)
    }

    func handleButtonClickEvent(
        buttonType: AnalyticsManager.EventType.ButtonType = .primary,
        label: String,
        sender: String,
        properties: [String: Any] = [:]
    ) {
        handle(eventType: .buttonClick(type: buttonType, label: label), properties: properties, label: label, sender: sender)
    }
}

// MARK: - Protocol

/// Abstracts analytics tracking so the concrete `AnalyticsManager` singleton is never
/// hard-coded at call sites. Inject a `NullAnalyticsManager` in tests/Previews:
///
///     .environment(\.analyticsManager, NullAnalyticsManager())
///
protocol AnalyticsManagerProtocol {
    func handleScreenIn(appScreen: AppScreen)
    func handleCustomEvent(
        eventType: AnalyticsManager.EventType,
        properties: [String: Any],
        sender: String
    )
    func handleAppLifeCycleEvent(
        label: String,
        sender: String,
        properties: [String: Any]
    )
    func handleListItemTapEvent(
        label: String,
        sender: String,
        properties: [String: Any]
    )
    func handleButtonClickEvent(
        buttonType: AnalyticsManager.EventType.ButtonType,
        label: String,
        sender: String,
        properties: [String: Any]
    )
}

// MARK: - SwiftUI Environment

private struct AnalyticsManagerKey: EnvironmentKey {
    /// Production default — the real singleton. Override in tests via
    /// `.environment(\.analyticsManager, NullAnalyticsManager())`.
    static let defaultValue: any AnalyticsManagerProtocol = AnalyticsManager.shared
}

extension EnvironmentValues {
    var analyticsManager: any AnalyticsManagerProtocol {
        get { self[AnalyticsManagerKey.self] }
        set { self[AnalyticsManagerKey.self] = newValue }
    }
}

// MARK: - Null implementation

/// No-op analytics manager for unit tests and Xcode Previews.
/// Prevents real Firebase events from being fired when no analytics backend is desired.
struct NullAnalyticsManager: AnalyticsManagerProtocol {
    func handleScreenIn(appScreen: AppScreen) {}
    func handleCustomEvent(
        eventType: AnalyticsManager.EventType,
        properties: [String: Any],
        sender: String
    ) {}
    func handleAppLifeCycleEvent(
        label: String,
        sender: String,
        properties: [String: Any]
    ) {}
    func handleListItemTapEvent(
        label: String,
        sender: String,
        properties: [String: Any]
    ) {}
    func handleButtonClickEvent(
        buttonType: AnalyticsManager.EventType.ButtonType,
        label: String,
        sender: String,
        properties: [String: Any]
    ) {}
}

// MARK: - Conformance
// All required methods are already implemented above; no extra code needed.
extension AnalyticsManager: AnalyticsManagerProtocol {}

private extension AnalyticsManager {
    /// Single funnel for all events: validates, attaches `sender`/`label` as
    /// parameters, and logs with a Firebase-safe event name.
    func handle(eventType: EventType, properties: [String: Any], label: String?, sender: String) {
        guard FirebaseApp.configIsValidAndAvailable else {
            return
        }
        if let label = label {
            DevTools.assert(!label.isEmpty, message: "Empty label")
        }
        DevTools.assert(!sender.isEmpty, message: "Empty sender")
        var eventProperties = properties
        eventProperties["sender"] = sender
        if let label = label {
            eventProperties["label"] = label
        }
        DevTools.Log.debug(.log("\(AnalyticsManager.self) : \(eventType)"), .business)
        #if FIREBASE_ENABLED
        Analytics.logEvent(eventType.firebaseEventName, parameters: eventProperties)
        #endif
    }
}
