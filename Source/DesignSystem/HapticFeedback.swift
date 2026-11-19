//
//  HapticFeedback.swift
//  DesignSystem
//
//  Created by Ricardo Santos on 01/07/2026.
//

import UIKit

/// Centralised haptic feedback so confirm-style actions (logging a hit,
/// saving, archiving) feel consistent across the app.
public enum HapticFeedback {
    /// Physical "tap registered" confirmation. Sound can be missed (silent
    /// mode, headphones off); haptics can't.
    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    public static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
