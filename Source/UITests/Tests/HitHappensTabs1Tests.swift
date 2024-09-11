//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

/*
 https://medium.com/@jpmtech/level-up-your-career-by-adding-ui-tests-to-your-swiftui-app-37cbffeba459
 */

@testable import HitHappens_Dev

import XCTest
import Combine
import Nimble
//
import Common

final class HitHappensTabs1Tests: BaseUITests {
    let enabled = true
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    func test_routeToEntityDetailsAndBack() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])
        tap(staticText: Constants.Entities.Book.name, on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)
        tap(button: Accessibility.backButton.identifier, on: app)
        exists(staticText: Constants.tab1Title, on: app)
    }

    func test_routeToEntityDetailsAndEdit() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])

        let newName = Constants.Entities.Book.alternativeName
        let newInfo = "New info"
        tap(staticText: Constants.Entities.Book.name, on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)
        tap(button: Accessibility.editButton.identifier, on: app)
        tap(
            textField: Accessibility.txtName.identifier,
            andType: newName,
            dismissKeyboard: false,
            on: app
        )
        tap(
            textField: Accessibility.txtInfo.identifier,
            andType: newInfo,
            dismissKeyboard: false,
            on: app
        )
        tap(button: Accessibility.confirmButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirmation alert
        tap(button: Accessibility.backButton.identifier, on: app) // Close details
        exists(staticText: Constants.tab1Title, on: app)
        exists(staticText: Constants.Entities.Book.alternativeName, on: app) // New name on favorits screen
    }

    func test_trackAddNewLogAndDelete() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])

        tapCounterWith(number: Constants.Entities.Book.logsCount)
        waitFor(staticText: Constants.alertWhenAddNewEvent, on: app)
        tap(
            staticText: Constants.alertWhenAddNewEvent,
            andWaitForStaticText: "\(Constants.entityOccurrenceSingle) details",
            on: app
        )
        tap(button: Accessibility.deleteButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirmation alert
        tapCounterWith(number: Constants.Entities.Book.logsCount) // We should have the same amount of book
    }

    func test_trackAddNewLog() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])

        tapCounterWith(number: Constants.Entities.Book.logsCount)
        waitFor(staticText: Constants.alertWhenAddNewEvent, on: app)
        tap(
            staticText: Constants.alertWhenAddNewEvent,
            andWaitForStaticText: "\(Constants.entityOccurrenceSingle) details",
            on: app
        )
    }

    func test_trackAddNewLogAndEdit() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])

        tapCounterWith(number: Constants.Entities.Book.logsCount)
        waitFor(staticText: Constants.alertWhenAddNewEvent, on: app)
        tap(
            staticText: Constants.alertWhenAddNewEvent,
            andWaitForStaticText: "\(Constants.entityOccurrenceSingle) details",
            on: app
        )
        tap(button: Accessibility.editButton.identifier, on: app)
        let info = String.randomWithSpaces(10)
        tap(
            textField: Accessibility.txtNote.identifier,
            andType: info,
            dismissKeyboard: false,
            on: app
        )
        tap(button: Accessibility.confirmButton.identifier, on: app)
        exists(staticText: info, on: app)
    }

    func test_deleteEntity() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])

        tap(staticText: Constants.Entities.Book.name, on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)

        tap(button: Accessibility.deleteButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirmation alert

        notExists(staticText: Constants.Entities.Book.name, on: app) // Deleted from favorits
        tap(
            tabBarIndex: Constants.tab2,
            andWaitForStaticText: Constants.tab2Title,
            on: app
        )
        notExists(listItemStaticText: Constants.Entities.Book.listItem, on: app) // Deleted from list
    }

    func test_deleteAllFavoritsAndAddNew() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])

        // Book
        tap(staticText: Constants.Entities.Book.name, on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)
        tap(button: Accessibility.deleteButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirmation alert
        notExists(staticText: Constants.Entities.Book.name, on: app)

        // Book
        tap(staticText: Constants.Entities.Coffee.name, on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)
        tap(button: Accessibility.deleteButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirmation alert
        notExists(staticText: Constants.Entities.Coffee.name, on: app)

        // Concerts
        tap(staticText: Constants.Entities.Concerts.name, on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)
        tap(button: Accessibility.deleteButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirmation alert
        notExists(staticText: Constants.Entities.Concerts.name, on: app)

        // Check message
        exists(staticText: Constants.noFavoritsMessage, on: app)
        tap(staticText: Constants.noFavoritsMessage, on: app)

        // Add new
        tap(
            textField: Accessibility.txtName.identifier,
            andType: Constants.Entities.Book.name,
            dismissKeyboard: false,
            on: app
        )

        tap(staticText: "Favorite", on: app) // Toggle favorite ON

        tap(button: Accessibility.saveButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirmation alert
        tap(button: Accessibility.backButton.identifier, on: app) // Close details

        // Route back
        exists(staticText: Constants.tab1Title, on: app)
        exists(staticText: Constants.Entities.Book.name, on: app)
    }
}
