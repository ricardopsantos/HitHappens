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

//
// MARK: - Misc
//
public extension XCTestCase {
    static var timeout: Double = 5

    func describe(app: XCUIApplication) {
        let secureTextFields = app.secureTextFields.allElementsBoundByIndex
            .map { $0.describe(false) }
        let textFields = app.textFields.allElementsBoundByIndex
            .map { $0.describe(false) }
        let staticTexts = app.staticTexts.allElementsBoundByIndex
            .map { $0.describe(false) }
        let buttons = app.buttons.allElementsBoundByIndex
            .map { $0.describe(false) }
        let toggles = app.toggles.allElementsBoundByIndex
            .map { $0.describe(false) }
        let otherElements = app.otherElements.allElementsBoundByIndex
            .map { $0.describe(false) }
        let scrollViews = app.scrollViews.allElementsBoundByIndex
            .map { $0.describe(false) }
        var result = "\n"
        if !scrollViews.isEmpty {
            result += "# scrollViews[\(scrollViews.count)]: \(scrollViews)" + "\n"
        }
        if !otherElements.isEmpty {
            result += "# otherElements[\(otherElements.count)]: \(otherElements)" + "\n"
        }
        if !toggles.isEmpty {
            result += "# toggles[\(toggles.count)]: \(toggles)" + "\n"
        }
        if !secureTextFields.isEmpty {
            result += "# secureTextFields[\(secureTextFields.count)]: \(secureTextFields)" + "\n"
        }
        if !textFields.isEmpty {
            result += "# textFields[\(textFields.count)]: \(textFields)" + "\n"
        }
        if !staticTexts.isEmpty {
            result += "# staticTexts[\(staticTexts.count)]: \(staticTexts)" + "\n"
        }
        if !buttons.isEmpty {
            result += "# buttons[\(buttons.count)]: \(buttons)" + "\n"
        }
        Common_Logs.debug(result)
    }
}
