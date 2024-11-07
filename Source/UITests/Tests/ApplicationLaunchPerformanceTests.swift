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
import DevTools

final class ApplicationLaunchPerformanceTests: BaseUITests {
    let enabled = !DevTools.onTargetProduction
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

    func testA1_launch() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        // Duration (AppLaunch): 1.445 s
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
