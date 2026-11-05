//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

/// @testable import comes from the ´PRODUCT_NAME´ on __.xcconfig__ file

@testable import HitHappens_Dev

import XCTest
import Combine
//
import Common
import Domain
import Core

let cancelBag = CancelBag()
var timeout: Int = 5
var loadedAny: Any?

extension XCTestCase {
    /// Polls the main run loop until `condition` is true or `timeout` seconds pass, then asserts it.
    func assertEventually(timeout: Int, _ message: String = "", file: StaticString = #filePath, line: UInt = #line, _ condition: () -> Bool) {
        let deadline = Date().addingTimeInterval(TimeInterval(timeout))
        while !condition() && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }
        XCTAssertTrue(condition(), message, file: file, line: line)
    }
}

class BaseViewModelsTests: XCTestCase {
    lazy var dataBaseRepository: DataBaseRepositoryProtocol = { DependenciesManager.Repository.dataBaseRepository }()
    lazy var secureAppPreferences: SecureAppPreferencesProtocol = { DependenciesManager.Repository.secureAppPreferences }()
    lazy var nonSecureAppPreferences: NonSecureAppPreferencesProtocol = { DependenciesManager.Repository.nonSecureAppPreferences }()
}
