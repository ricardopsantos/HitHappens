//
//  NetworkManager_Tests.swift
//
//  Created by Ricardo Santos on 08/08/2024.
//

@testable import HitHappens_Dev

import XCTest
import Combine
//
import Domain
import Core
import Common

final class NetworkManagerTests: XCTestCase {
    let enabled = true
    lazy var networkManager: NetworkManagerProtocol = { NetworkManager.shared }()
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

extension NetworkManagerTests {
    // Test to verify that CompanyInfo information can be fetched
    func test_requestCompanyInfo() async {
        guard enabled else {
            XCTAssert(true)
            return
        }
        do {
            // Attempt to fetch CompanyInfo
            let result: ModelDto.AppConfigResponse? = try await networkManager.requestAsync(.getAppConfiguration(.init()))

            // Verify that CompanyInfo was successfully loaded
            XCTAssertTrue(result != nil, "data should be loaded successfully.")
        } catch {
            // In case of an error, fail the test
            XCTAssertTrue(false, "Failed to fetch with error: \(error)")
        }
    }
}

//
// MARK: - Performance Tests
//

extension NetworkManagerTests {
    func test_requestCompanyInfo_Performance_Load() throws {
        guard enabled else {
            XCTAssert(true)
            return
        }
        let expectedTime: Double = 0.3
        measure {
            let expectation = expectation(description: #function)
            Task {
                do {
                    let _: ModelDto.AppConfigResponse? = try await networkManager.requestAsync(.getAppConfiguration(.init()))
                    expectation.fulfill()
                } catch {
                    XCTFail("Async function threw an error: \(error)")
                }
            }
            wait(for: [expectation], timeout: expectedTime * 1.25)
        }
    }
}
