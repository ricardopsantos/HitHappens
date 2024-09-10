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

final class HitHappensTabsTests: BaseUITests {
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
}
