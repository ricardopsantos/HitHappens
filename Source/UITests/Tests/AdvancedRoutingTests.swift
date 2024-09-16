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

final class AdvancedRoutingTests: BaseUITests {
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

    func test_createNewTrackerAndDelete() {
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
        let trackerName = "New tracker"
        tap(button: Accessibility.addButton.identifier, on: app)
        tap(textField: Accessibility.txtName.identifier, andType: trackerName, dismissKeyboard: false, on: app)
        tap(button: Accessibility.saveButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirm save
        tap(button: Accessibility.deleteButton.identifier, on: app)
        tap(button: "Yes", andWaitForStaticText: Constants.tab2Title, on: app) // Confirm delete

        notExists(staticText: trackerName, on: app)
    }

    func test_loadTrackerAndDeleteTab1() {
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
    }

    func test_loadTrackerAndDeleteTab2() {
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
        tap(listItemStaticText: Constants.Entities.Book.listItem, on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)

        tap(button: Accessibility.deleteButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirmation alert

        notExists(staticText: Constants.Entities.Book.listItem, on: app) // Deleted from list
        tap(
            tabBarIndex: Constants.tab1,
            andWaitForStaticText: Constants.tab1Title,
            on: app
        )
        notExists(staticText: Constants.Entities.Book.name, on: app) // Deleted from favorits
    }

    func test_createNewTrackerAndAddLogAndRouteToLogAndRouteToTrackerDetailsAndDeleteTracker() {
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
        let trackerName = "New tracker"
        tap(button: Accessibility.addButton.identifier, on: app)
        tap(textField: Accessibility.txtName.identifier, andType: trackerName, dismissKeyboard: false, on: app)
        tap(button: Accessibility.saveButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirm save

        trackerDetailsTapCounterWith(number: 0)
        tap(
            staticText: Accessibility.txtAlertModelText.identifier,
            on: app
        )

        tap(
            button: "\(Constants.entityNameSingle) details",
            andWaitForStaticText: "\(Constants.entityOccurrenceSingle) details",
            on: app
        )

        tap(button: Accessibility.deleteButton.identifier, on: app)

        tap(button: "Yes", on: app) // Confirm delete
        exists(staticText: Constants.tab2Title, on: app) // Assure we route back to list
        notExists(staticText: trackerName, on: app)
    }
}
