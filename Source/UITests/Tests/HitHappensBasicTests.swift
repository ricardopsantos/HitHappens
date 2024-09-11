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

final class HitHappensOnboardingTests: BaseUITests {
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
        wait(delay: 3)
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
}
