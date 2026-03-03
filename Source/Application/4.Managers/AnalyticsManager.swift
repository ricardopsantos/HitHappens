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
    struct BaseEvent {
        let eventType: EventType
        var eventProperties: [String: Any] = [:]
    }

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
        guard FirebaseApp.configIsValidAndAvailable else {
            return
        }
        var newProperties = properties
        newProperties["sender"] = sender
        let baseEvent = BaseEvent(eventType: eventType, eventProperties: properties)
        handle(baseEvent: baseEvent)
    }

    func handleAppLifeCycleEvent(
        label: String,
        sender: String,
        properties: [String: Any] = [:]
    ) {
        guard FirebaseApp.configIsValidAndAvailable else {
            return
        }
        DevTools.assert(!label.isEmpty, message: "Empty label")
        DevTools.assert(!sender.isEmpty, message: "Empty sender")
        var newProperties = properties
        newProperties["sender"] = sender
        let baseEvent = BaseEvent(eventType: EventType.appLifeCycleEvent(label: label), eventProperties: properties)
        handle(baseEvent: baseEvent)
    }

    func handleListItemTapEvent(
        label: String,
        sender: String,
        properties: [String: Any] = [:]
    ) {
        guard FirebaseApp.configIsValidAndAvailable else {
            return
        }
        DevTools.assert(!label.isEmpty, message: "Empty label")
        DevTools.assert(!sender.isEmpty, message: "Empty sender")
        var newProperties = properties
        newProperties["sender"] = sender
        let baseEvent = BaseEvent(eventType: EventType.listItemTap(label: label), eventProperties: properties)
        handle(baseEvent: baseEvent)
    }

    func handleButtonClickEvent(
        buttonType: AnalyticsManager.EventType.ButtonType = .primary,
        label: String,
        sender: String,
        properties: [String: Any] = [:]
    ) {
        guard FirebaseApp.configIsValidAndAvailable else {
            return
        }
        DevTools.assert(!label.isEmpty, message: "Empty label")
        DevTools.assert(!sender.isEmpty, message: "Empty sender")
        var newProperties = properties
        newProperties["sender"] = sender
        let baseEvent = BaseEvent(
            eventType: EventType.buttonClick(
                type: buttonType,

                label: label
            ),
            eventProperties: properties
        )
        handle(baseEvent: baseEvent)
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
    func handle(baseEvent: BaseEvent) {
        guard FirebaseApp.configIsValidAndAvailable else {
            return
        }
        DevTools.Log.debug(.log("\(AnalyticsManager.self) : \(baseEvent.eventType)"), .business)
        #if FIREBASE_ENABLED
        Analytics.logEvent(baseEvent.eventType.rawValue, parameters: baseEvent.eventProperties)
        #endif
    }
}
