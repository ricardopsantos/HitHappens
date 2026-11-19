//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import XCTest
//
import Common

//
// https://www.appcoda.com/ui-testing-swiftui-xctest/
//

fileprivate extension XCTestCase {
    func exists(
        anyStaticText: String,
        on app: XCUIApplication
    ) -> Bool {
        var result = false
        if !result {
            app.scrollViews.staticTexts.allElementsBoundByIndex.forEach { xcuiElement in
                if xcuiElement.label == anyStaticText {
                    result = true
                }
            }
        }
        if !result {
            app.scrollViews.otherElements.staticTexts.allElementsBoundByIndex.forEach { xcuiElement in
                if xcuiElement.label == anyStaticText {
                    result = true
                }
            }
        }

        if !result {
            app.collectionViews.staticTexts.allElementsBoundByIndex.forEach { xcuiElement in
                if xcuiElement.label == anyStaticText {
                    result = true
                }
            }
        }
        if !result {
            app.collectionViews.otherElements.staticTexts.allElementsBoundByIndex.forEach { xcuiElement in
                if xcuiElement.label == anyStaticText {
                    result = true
                }
            }
        }
        app.otherElements.staticTexts.allElementsBoundByIndex.forEach { xcuiElement in
            if xcuiElement.label == anyStaticText {
                result = true
            }
        }
        return result
    }
}

public extension XCTestCase {
    func exists(
        staticText: String,
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        XCTAssert(app.staticTexts[staticText].waitForExistence(timeout: timeout))
    }

    func notExists(
        staticText: String,
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        // Wait for the element to DISAPPEAR (not just "not appear"): after a delete the
        // screen/list may still show the item for a few frames while it animates out.
        let gone = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.staticTexts[staticText])
        let result = XCTWaiter().wait(for: [gone], timeout: timeout)
        XCTAssertEqual(result, .completed, "'\(staticText)' still exists after \(timeout)s")
    }
}
