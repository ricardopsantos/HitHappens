//
//  Accessibility.swift
//  DesignSystem
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation

public enum Accessibility: String, CaseIterable {
    // Text Fields
    case txtName
    case txtInfo
    case txtNote
    case txtUserName
    case txtEmail
    case txtPassword

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
    case editButton
    case confirmButton
    case cancelButton

    // CheckBox
    case readTermsAndConditions
    case scrollView

    // Not applied
    case undefined

    public var identifier: String {
        rawValue
    }
}
