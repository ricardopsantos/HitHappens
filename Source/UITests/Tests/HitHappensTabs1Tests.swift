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
        tap(staticText: Constants.booksEntityName, on: app)
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
        tap(
            tabBarIndex: Constants.tab2,
            andWaitForStaticText: Constants.tab2Title,
            on: app
        )
        let newName = Constants.booksEntityName + "_V2"
        let newInfo = "New info"
        tap(staticText: Constants.booksListItem, on: app)
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
        exists(staticText: Constants.tab2Title, on: app)
        let newListItem = Constants.booksListItem.replace(Constants.booksEntityName, with: newName)
        exists(staticText: newListItem, on: app) // New name on favorits screen
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

        tapCounterWith(number: Constants.bookLogsCount)
        waitFor(staticText: Constants.alertWhenAddNewEvent, on: app)
        tap(
            staticText: Constants.alertWhenAddNewEvent,
            andWaitForStaticText: "\(Constants.entityOccurrenceSingle) details",
            on: app
        )
        tap(button: Accessibility.deleteButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirmation alert
        tapCounterWith(number: Constants.bookLogsCount) // We should have the same amount of book
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

        tapCounterWith(number: Constants.bookLogsCount)
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

        tapCounterWith(number: Constants.bookLogsCount)
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
}
