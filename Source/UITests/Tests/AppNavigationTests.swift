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

final class AppNavigationTests: BaseUITests {
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

    func test_onboardingComplete() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])
        exists(staticText: Constants.tab1Title, on: app)
    }

    func test_onboardingNotComplete() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent
        ])
        let intro = ModelDto.AppConfigResponse.mock?.hitHappens.onboarding.intro ?? ""
        exists(staticText: intro, on: app)
    }

    func test_performOnboarding() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent
        ])
        auxiliar_performOnBoarding()
        exists(staticText: Constants.tab1Title, on: app)
    }

    func test_changeTabs() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])
        exists(staticText: Constants.tab1Title, on: app)
        tap(
            tabBarIndex: Constants.tab2,
            andWaitForStaticText: Constants.tab2Title,
            on: app
        )
        tap(
            tabBarIndex: Constants.tab3,
            andWaitForStaticText: Constants.tab3Title,
            on: app
        )
        tap(
            tabBarIndex: Constants.tab3,
            andWaitForStaticText: Constants.tab3Title,
            on: app
        )
        tap(
            tabBarIndex: Constants.tab4,
            andWaitForStaticText: Constants.tab4Title,
            on: app
        )
        tap(
            tabBarIndex: Constants.tab5,
            andWaitForStaticText: Constants.tab5Title,
            on: app
        )
    }

    func test_tab1_routeToDetailsAndBack() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])
        tap(staticText: "Books", on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)
        tap(button: Accessibility.backButton.identifier, on: app)
        exists(staticText: Constants.tab1Title, on: app)
    }

    func test_Tab1_TrackAddNewLog() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllContent,
            .isOnboardingCompleted
        ])

        tapCounterWith(number: 3)
        waitFor(staticText: Constants.alertWhenAddNewEvent, on: app)
        tap(
            staticText: Constants.alertWhenAddNewEvent,
            andWaitForStaticText: "\(Constants.entityOccurrenceSingle) details",
            on: app
        )
    }

    func test_Tab2_routeToDetailsAndBack() {
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
        tap(staticText: Constants.books, on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)
        tap(button: Accessibility.backButton.identifier, on: app)
        exists(staticText: Constants.tab2Title, on: app)
    }

    func test_Tab2_addNewTracker() {
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
        let newEventName = "New Event"
        tap(button: Accessibility.addButton.identifier, on: app)
        tap(
            textField: Accessibility.txtName.identifier,

            andType: newEventName,
            dismissKeyboard: false,
            on: app
        )
        tap(button: Accessibility.saveButton.identifier, on: app)
        tap(button: "Yes", on: app) // Save alert confirmation
        exists(staticText: "\(Constants.entityNameSingle) details", on: app) // On details screen (non edit)
        exists(staticText: newEventName, on: app)
        tap(button: Accessibility.backButton.identifier, on: app) // Close
        exists(staticText: newEventName, on: app) // Back to list
    }

    func test_Tab2_deleteTracker() {
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
        tap(staticText: Constants.books, on: app)
        exists(staticText: "\(Constants.entityNameSingle) details", on: app)
        tap(button: Accessibility.deleteButton.identifier, on: app)
        tap(button: "Yes", on: app) // Save alert confirmation
        exists(staticText: "\(Constants.tab2Title)", on: app)
    }
}
