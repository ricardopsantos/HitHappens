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
