//
//  AnalyticsManagerProtocol.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI

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
