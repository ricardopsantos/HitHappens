//
//  InterfaceStyle.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Core
import Common
import DesignSystem
import DevTools

struct InterfaceStyleManager {
    static var nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    static func setup(nonSecureAppPreferences: NonSecureAppPreferencesProtocol?) {
        Self.nonSecureAppPreferences = nonSecureAppPreferences
        applyAppearance(selectedByUser)
    }

    /// If the user has any InterfaceStyle chosen, will return that style
    private static var _selectedByUser: Common.InterfaceStyle?
    static var selectedByUser: Common.InterfaceStyle? {
        get {
            if let _selectedByUser = _selectedByUser {
                return _selectedByUser
            }
            if let selectedAppearance = nonSecureAppPreferences?.selectedAppearance {
                return Common.InterfaceStyle(rawValue: selectedAppearance)
            }
            return nil
        }
        set {
            applyAppearance(newValue)
        }
    }

    static var appInterfaceStyle: Common.InterfaceStyle {
        if let selectedByUser = selectedByUser {
            return selectedByUser
        } else {
            return Common.InterfaceStyle.current
        }
    }

    static func applyAppearance(_ style: Common.InterfaceStyle?) {
        DevTools.assert(nonSecureAppPreferences != nil, message: "nonSecureAppPreferences not set")
        guard style != _selectedByUser else {
            return
        }
        Common_Utils.executeInMainTread {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    ColorSemantic.applyUserCustomInterfaceStyle(style)
                    _selectedByUser = style
                    switch style {
                    case .light:
                        window.overrideUserInterfaceStyle = .light
                        nonSecureAppPreferences?.selectedAppearance = Common.InterfaceStyle.light.rawValue
                    case .dark:
                        window.overrideUserInterfaceStyle = .dark
                        nonSecureAppPreferences?.selectedAppearance = Common.InterfaceStyle.dark.rawValue
                    case .none:
                        nonSecureAppPreferences?.selectedAppearance = nil
                        window.overrideUserInterfaceStyle = .unspecified
                    }
                }
            }
        }
    }
}
