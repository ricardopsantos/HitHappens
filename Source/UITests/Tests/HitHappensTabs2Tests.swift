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

    func test_routeToEntityDetailsAndEdit() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])
        let newName = Constants.booksEntityName + "_V2"
        let newInfo = "New info"
        tap(staticText: Constants.booksEntityName, on: app)
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
        exists(staticText: Constants.tab1Title, on: app)
        tap(button: Accessibility.backButton.identifier, on: app) // Close details
        exists(staticText: newName, on: app) // New name on favorits screen
    }
}
