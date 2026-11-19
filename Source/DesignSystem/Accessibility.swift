//
//  Accessibility.swift
//  DesignSystem
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation

public enum Accessibility: String, CaseIterable {
    // Text Fields
    case txtAlertModelText
    case txtName
    case txtInfo
    case txtNote
    case txtUserName
    case txtEmail
    case txtPassword
    case txtSearch

    // Toggle
    case toggleFavorits

    // Buttons
    case detailsButton
    case loginButton
    case logoutButton
    case deleteButton
    case resetButton
    case saveButton
    case fwdButton
    case backButton
    case addButton
    case emptyStateAddButton
    case editButton
    case confirmButton
    case cancelButton
    case undoButton
    case skipButton
    case supportButton
    case publicCodeButton
    case onboardingButton

    // CheckBox
    case readTermsAndConditions
    case scrollView

    // Not applied
    case undefined

    public var identifier: String {
        rawValue
    }
}
