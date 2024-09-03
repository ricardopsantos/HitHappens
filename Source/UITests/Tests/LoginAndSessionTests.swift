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

final class LoginAndSessionTests: BaseUITests {
    let enabled = false
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

    //
    // MARK: - testAxxx : Splash Screen
    //

    func testA1_welcomeScreen() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllPreferences
        ])
        waitFor(staticText: "Welcome", on: app)
    }

    //
    // MARK: - testBxxx :Login
    //

    func testB1_login() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllPreferences
        ])
        auxiliar_performLogin()
    }

    func testB2_onBoarding() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .shouldResetAllPreferences
        ])
        auxiliar_performLogin()
        auxiliar_performOnBoarding()
    }

    //
    // MARK: - testBxxx :Logout
    //

    func testC1_logoutCancel() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .isAuthenticated
        ])
        tap(
            tabBarIndex: Constants.tabBarSettings,
            andWaitForStaticText: Constants.tab4Title,
            on: app
        )
        tap(
            button: "Logout",
            andWaitForStaticText: "LogoutBottomSheetTitle",
            on: app
        )
        tap(
            button: "No",
            andWaitForStaticText: Constants.tab4Title,
            on: app
        )
    }

    func testC2_logoutConfirm() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .isAuthenticated
        ])
        tap(
            tabBarIndex: Constants.tabBarSettings,
            andWaitForStaticText: Constants.tab4Title,
            on: app
        )
        tap(
            button: "Logout",
            andWaitForStaticText: "LogoutBottomSheetTitle",
            on: app
        )
        tap(
            button: "Yes",
            andWaitForStaticText: "Welcome",
            on: app
        )
    }

    //
    // MARK: - testCxxx : Delete Account
    //

    func testC1_deleteAccountCancel() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .isAuthenticated
        ])
        tap(
            tabBarIndex: Constants.tabBarSettings,
            andWaitForStaticText: Constants.tab4Title,
            on: app
        )
        tap(
            button: "DeleteAccount",
            andWaitForStaticText: "DeleteAccountBottomSheetTitle",
            on: app
        )
        tap(
            button: "No",
            andWaitForStaticText: Constants.tab4Title,
            on: app
        )
    }

    func testC2_deleteAccountConfirm() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            .isAuthenticated
        ])
        tap(
            tabBarIndex: Constants.tabBarSettings,
            andWaitForStaticText: Constants.tab4Title,
            on: app
        )
        tap(
            button: "DeleteAccount",
            andWaitForStaticText: "DeleteAccountBottomSheetTitle",
            on: app
        )
        tap(
            button: "Yes",
            andWaitForStaticText: "Welcome",
            on: app
        )
    }
}
