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

public extension XCUIApplication {
    func elementIsWithinWindow(element: XCUIElement) -> Bool {
        guard element.exists, !element.frame.isEmpty, element.isHittable else { return false }
        return windows.element(boundBy: 0).frame.contains(element.frame)
    }

    func scrollDown(times: Int = 1) {
        let mainWindow = windows.firstMatch
        let topScreenPoint = mainWindow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05))
        let bottomScreenPoint = mainWindow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.90))
        for _ in 0..<times {
            bottomScreenPoint.press(forDuration: 0, thenDragTo: topScreenPoint)
        }
    }

    func scrollUp(times: Int = 1) {
        let mainWindow = windows.firstMatch
        let topScreenPoint = mainWindow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05))
        let bottomScreenPoint = mainWindow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.90))
        for _ in 0..<times {
            topScreenPoint.press(forDuration: 0, thenDragTo: bottomScreenPoint)
        }
    }

    func scrollUntilElementAppears(element: XCUIElement, threshold: Int = 10) {
        var iteration = 0

        while !elementIsWithinWindow(element: element) {
            guard iteration < threshold else { break }
            scrollDown()
            iteration += 1
        }

        if !elementIsWithinWindow(element: element) {
            scrollDown(times: threshold)
        }

        while !elementIsWithinWindow(element: element) {
            guard iteration > 0 else { break }
            scrollUp()
            iteration -= 1
        }
    }
}
