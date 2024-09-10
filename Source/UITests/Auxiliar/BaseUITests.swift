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

class BaseUITests: XCTestCase {
    lazy var app: XCUIApplication = {
        let app = XCUIApplication()
        return app
    }()

    func appLaunch(launchArguments: [UITestingOptions]) {
        app.launchArguments = launchArguments.map(\.rawValue) + [
            UITestingOptions.onUITesting.rawValue,
            UITestingOptions.shouldDisableAnimations.rawValue,
            UITestingOptions.firebaseDisabled.rawValue
        ]
        app.launch()
    }
}

extension BaseUITests {
    func editEntity(newName: String, newInfo: String, newCategory: String, newSoundEffect: String) {
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
        tap(staticText: Constants.Entities.Book.soundEffect, on: app)
        tap(button: newSoundEffect, on: app)
        tap(staticText: Constants.Entities.Book.category, on: app)
        tap(button: newCategory, on: app)
    }

    func tapCounterWith(number: Int) {
        if number < 10 {
            app.scrollViews.otherElements.images["\(number)00"].tap()
        } else {
            app.scrollViews.otherElements.images["\(number)0"].tap()
        }
    }

    func auxiliar_performOnBoarding() {
        //
        // Onboarding screen
        //
        tap(button: Accessibility.fwdButton.identifier, on: app) // 2º page
        tap(button: Accessibility.fwdButton.identifier, on: app) // 3º page
        tap(button: Accessibility.fwdButton.identifier, on: app) // 4º page
        tap(button: Accessibility.fwdButton.identifier, on: app) // 5º page
        tap(button: Accessibility.fwdButton.identifier, andWaitForStaticText: Constants.tab1Title, on: app)
    }
}
