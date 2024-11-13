//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

/// @testable import comes from the ´PRODUCT_NAME´ on __.xcconfig__ file

@testable import HitHappens_Dev

import XCTest
import Combine
import Nimble
//
import Domain
import Core
import Common
import DevTools

final class AppConfigServiceTests: XCTestCase {
    let enabled = !DevTools.onTargetProduction
    let loadExpectedTime: Double = 1
    lazy var service: AppConfigServiceProtocol = { DependenciesManager.Services.appConfigService }()
    lazy var serviceMock: AppConfigServiceProtocol = { DependenciesManager.Services.appConfigServiceMock }()
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
    }
}

//
// MARK: - Tests
//

extension AppConfigServiceTests {
    // Test to verify mock
    func test_mock() async {
        guard enabled else {
            XCTAssert(true)
            return
        }
        DevTools.Log.debug("Test #\(#function) will start", .business)
        XCTAssertTrue(ModelDto.AppConfigResponse.mock != nil, "mock data should be loaded successfully.")
    }

    func test_requestAppConfig() async {
        guard enabled else {
            XCTAssert(true)
            return
        }
        DevTools.Log.debug("Test #\(#function) will start", .business)
        do {
            // Attempt to fetch
            loadedAny = try await service.requestAppConfig(.init(), cachePolicy: .load)

            // Verify was successfully loaded
            XCTAssertTrue(loadedAny != nil, "data should be loaded successfully.")
        } catch {
            // In case of an error, fail the test
            XCTAssertTrue(false, "Failed to fetch with error: \(error)")
        }
    }
}

//
// MARK: - Performance Tests
//

extension AppConfigServiceTests {
    func test_requestAppConfig_Performance_Load() throws {
        guard enabled else {
            XCTAssert(true)
            return
        }
        DevTools.Log.debug("Test #\(#function) will start", .business)

        let cachePolicy: ServiceCachePolicy = .load
        let expectedTime: Double = loadExpectedTime
        let count = 10
        // Time: 0.498 sec
        measure {
            let expectation = expectation(description: #function)
            Task {
                do {
                    _ = try await service.requestAppConfig(
                        .init(),
                        cachePolicy: cachePolicy
                    )
                    expectation.fulfill()
                } catch {
                    XCTFail("Async function threw an error: \(error)")
                }
            }
            wait(for: [expectation], timeout: expectedTime * 1.25 * Double(count))
        }
    }

    func test_requestAppConfig_Performance_CacheElseLoad() throws {
        guard enabled else {
            XCTAssert(true)
            return
        }
        DevTools.Log.debug("Test #\(#function) will start", .business)
        let cachePolicy: ServiceCachePolicy = .cacheElseLoad
        let expectedTime: Double = loadExpectedTime / 3
        let count = 10
        // Time: 0.009 sec
        measure {
            let expectation = expectation(description: #function)
            Task {
                do {
                    _ = try await service.requestAppConfig(
                        .init(),
                        cachePolicy: cachePolicy
                    )
                    expectation.fulfill()
                } catch {
                    XCTFail("Async function threw an error: \(error)")
                }
            }
            wait(for: [expectation], timeout: expectedTime * 1.25 * Double(count))
        }
    }
}
