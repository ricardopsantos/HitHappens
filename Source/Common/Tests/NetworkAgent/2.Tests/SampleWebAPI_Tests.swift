//
//  Created by Ricardo Santos on 12/08/2024.
//

import XCTest
import Foundation
import Combine
//
@testable import Common
class SampleWebAPI_Tests: XCTestCase {
    func enabled() -> Bool {
        true
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        TestsGlobal.loadedAny = nil
        TestsGlobal.cancelBag.cancel()
    }

    private var sampleWebAPIUseCase: SampleWebAPIUseCase {
        SampleWebAPIUseCase()
    }

    func test_fetchEmployeesAvailabilityCustom() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        sampleWebAPIUseCase.fetchEmployeesAvailabilityCustom()
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        waitUntil(TimeInterval(TestsGlobal.timeout)) { counter == 1 }
        XCTAssertEqual(counter, 1)
    }

    func test_fetchEmployeesAvailabilityGenericPublisher() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        sampleWebAPIUseCase.fetchEmployeesPublisher()
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        waitUntil(TimeInterval(TestsGlobal.timeout)) { counter == 1 }
        XCTAssertEqual(counter, 1)
    }

    func test_fetchEmployeesAvailabilityGenericAsync() async {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        let value = try? await sampleWebAPIUseCase.fetchEmployeesAsync()
        XCTAssertNotNil(value)
    }

    func test_fetchEmployeesAvailabilityCustomWithCache() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        sampleWebAPIUseCase.fetchEmployees(cachePolicy: .cacheElseLoad)
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        waitUntil(TimeInterval(TestsGlobal.timeout)) { counter == 1 }
        XCTAssertEqual(counter, 1)
    }

    func test_fetchEmployeesAvailabilityGenericPublisherWithCache() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        sampleWebAPIUseCase.fetchEmployees(cachePolicy: .cacheElseLoad)
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        waitUntil(TimeInterval(TestsGlobal.timeout)) { counter == 1 }
        XCTAssertEqual(counter, 1)
    }

    func test_sslPiningWithCertificates() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        sampleWebAPIUseCase.fetchEmployeesAvailabilitySLLCertificate(server: .gitHub)
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        waitUntil(TimeInterval(TestsGlobal.timeout)) { counter == 1 }
        XCTAssertEqual(counter, 1)
    }

    func test_sslPiningWithPublicHashKeys() async {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        let value = try? await sampleWebAPIUseCase.fetchEmployeesAvailabilitySLLHashKeys(server: .gitHub).async()
        XCTAssertNotNil(value)
    }

    func test_authenticationHandlerWithHashKeys() async {
        let server: CommonNetworking.AuthenticationHandler.Server = .googleUkWithHashKeys
        let delegate = CommonNetworking.AuthenticationHandler(server: server)

        let urlSession = URLSession(
            configuration: .defaultForNetworkAgent(),
            delegate: delegate,
            delegateQueue: nil
        )

        let request = URLRequest(url: URL(string: server.url)!)
        do {
            _ = try await urlSession.data(for: request)
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
    }

    func test_authenticationHandlerWithCertPath() async {
        let server: CommonNetworking.AuthenticationHandler.Server = .googleUkWithCertPath
        let delegate = CommonNetworking.AuthenticationHandler(server: server)

        let urlSession = URLSession(
            configuration: .defaultForNetworkAgent(),
            delegate: delegate,
            delegateQueue: nil
        )

        let request = URLRequest(url: URL(string: server.url)!)
        do {
            _ = try await urlSession.data(for: request)
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
    }
}
