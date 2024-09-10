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

final class HitHappensTabs2Tests: BaseUITests {
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

    func test_routeToEntityDetailsAndEditConfirm() {
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
        let newName = Constants.booksAlternativeEntityName
        let newInfo = "New info"
        let newCategory = Constants.booksEntityAlternativeCategory
        let newSoundEffect = Constants.booksAlternativeSoundEffect
        tap(listItemStaticText: Constants.booksListItem, on: app)

        exists(staticText: "\(Constants.entityNameSingle) details", on: app)

        editEntity(newName: newName, newInfo: newInfo, newCategory: newCategory, newSoundEffect: newSoundEffect)
        tap(button: Accessibility.confirmButton.identifier, on: app)

        tap(button: "Yes", on: app) // Confirmation alert

        tap(button: Accessibility.backButton.identifier, on: app) // Close details
        exists(listItemStaticText: Constants.booksAlternativeListItem, on: app) // New name on favorits screen
        tap(listItemStaticText: Constants.booksAlternativeListItem, on: app) // Go back to details

        exists(staticText: newName, on: app)
        exists(staticText: newCategory, on: app)
        exists(staticText: newSoundEffect, on: app)
    }

    func test_routeToEntityDetailsAndEditCancel() {
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
        let newName = Constants.booksAlternativeEntityName
        let newInfo = "New info"
        let newCategory = Constants.booksEntityAlternativeCategory
        let newSoundEffect = Constants.booksAlternativeSoundEffect
        tap(listItemStaticText: Constants.booksListItem, on: app)

        exists(staticText: "\(Constants.entityNameSingle) details", on: app)

        editEntity(newName: newName, newInfo: newInfo, newCategory: newCategory, newSoundEffect: newSoundEffect)
        tap(button: Accessibility.confirmButton.identifier, on: app)

        tap(button: "No", on: app) // Confirmation alert

        notExists(staticText: newName, on: app)
        notExists(staticText: newCategory, on: app)
        notExists(staticText: newSoundEffect, on: app)

        exists(staticText: Constants.booksEntityName, on: app)
        exists(staticText: Constants.booksSoundEffect, on: app)
        exists(staticText: Constants.booksEntityCategory, on: app)
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
        tap(
            tabBarIndex: Constants.tab2,
            andWaitForStaticText: Constants.tab2Title,
            on: app
        )
        tap(listItemStaticText: Constants.booksListItem, on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)

        tap(button: Accessibility.deleteButton.identifier, on: app)
        tap(button: "Yes", on: app) // Confirmation alert

        notExists(listItemStaticText: Constants.booksListItem, on: app) // Deleted from list
        tap(
            tabBarIndex: Constants.tab1,
            andWaitForStaticText: Constants.tab1Title,
            on: app
        )
        notExists(staticText: Constants.booksEntityName, on: app) // Deleted from favorits
    }
}
