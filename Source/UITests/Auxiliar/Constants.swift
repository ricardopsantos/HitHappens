//
//  Constants.swift
//  HitHappensUITests
//
//  Created by Ricardo Santos on 08/08/2024.
//

import Foundation
import Common

let cancelBag = CancelBag()
var timeout: Int = 5
var loadedAny: Any?

extension Constants {
    enum Entities {
        enum Coffee {
            static let name = "Coffee"
        }

        enum Concerts {
            static let name = "Concerts \(Date().year)"
        }

        enum Book {
            static let alternativeCategory = "Cultural"
            static let category = "Personal"
            static let alternativeSoundEffect = "Duck"
            static let soundEffect = "Cheer 1"
            static let logsCount = 3
            static let name = "Books \(Date().year)"
            static let alternativeName = "Books \(Date().year)_V2"
            static let listItem = "\(name) | \(category)"
            static let alternativeListItem = "\(alternativeName) | \(alternativeCategory)"
        }
    }
}

enum Constants {
    static let entityNameSingle = "Tracker"
    static let entityNamePlural = "\(entityNameSingle)(s)"
    static let entityOccurrenceSingle = "Event"
    static let entityOccurrenceNamePlural = "\(entityOccurrenceSingle)(s)"
    //
    //
    static let alertWhenAddNewEvent = "\(Constants.entityOccurrenceSingle) tracked!\n\n(Tap here to edit/add details.)"
    static let noFavoritsMessage = "You don't have any \(entityNamePlural.lowercased()) marked as favorite\n\nTap to add one!"
    //
    //
    static let tab1 = 0
    static let tab1Title = "Favorites"
    //
    static let tab2 = 1
    static let tab2Title = "\(entityNamePlural)"
    //
    static let tab3 = 2
    static let tab3Title = "September 2024" // "\(Date().monthAndYear)"
    //
    static let tab4 = 3
    static let tab4Title = "\(entityOccurrenceNamePlural) by region"
    //
    static let tab5 = 4
    static let tab5Title = "Settings"
}

//
// Copy of `UITestingManager.Options` enum @ HitHappens Target
// Copy of `UITestingManager.Options` enum @ HitHappens Target
// Copy of `UITestingManager.Options` enum @ HitHappens Target
//
enum UITestingOptions: String {
    case onUITesting
    case shouldDisableAnimations
    case shouldResetAllContent
    case isOnboardingCompleted
    case firebaseDisabled
}

//
// Copy of `Accessibility` enum @ HitHappens Target
// Copy of `Accessibility` enum @ HitHappens Target
// Copy of `Accessibility` enum @ HitHappens Target
//
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
    case loginButton
    case logoutButton
    case deleteButton
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
