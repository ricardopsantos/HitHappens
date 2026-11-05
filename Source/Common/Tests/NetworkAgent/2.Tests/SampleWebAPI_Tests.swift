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

    // MARK: - Authentication handler (SSL pinning)
    //
    // These tests do NOT hard-code google.co.uk's certificate/key: Google rotates its leaf
    // certificate every few months and even serves different leaves (RSA / ECDSA) to different
    // connections, so fixed pins were time bombs. Instead, for each TLS challenge the pin is
    // derived from the very leaf certificate presented on that connection and the challenge is
    // forwarded to the handler under test: a matching pin must be accepted, a wrong one rejected.

    private final class ForwardingDelegate: NSObject, URLSessionDelegate {
        let makeHandler: (SecCertificate) -> CommonNetworking.AuthenticationHandler
        init(makeHandler: @escaping (SecCertificate) -> CommonNetworking.AuthenticationHandler) {
            self.makeHandler = makeHandler
        }

        func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            guard let trust = challenge.protectionSpace.serverTrust,
                  let leaf = SecTrustGetCertificateAtIndex(trust, 0) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            makeHandler(leaf).urlSession(session, didReceive: challenge, completionHandler: completionHandler)
        }
    }

    /// `true` if the request succeeded, `false` if the handler rejected the pin.
    /// Skips the test when the network itself is unavailable.
    private func request(
        _ url: String,
        makeHandler: @escaping (SecCertificate) -> CommonNetworking.AuthenticationHandler
    ) async throws -> Bool {
        let session = URLSession(configuration: .ephemeral, delegate: ForwardingDelegate(makeHandler: makeHandler), delegateQueue: nil)
        do {
            _ = try await session.data(from: URL(string: url)!)
            return true
        } catch let error as URLError where error.code == .cancelled {
            return false // challenge cancelled by the handler => pin rejected
        } catch {
            throw XCTSkip("Network unavailable: \(error)")
        }
    }

    func test_authenticationHandlerWithHashKeys() async throws {
        let url = CommonNetworking.AuthenticationHandler.Server.googleUkWithHashKeys.url

        let accepted = try await request(url) { leaf in
            .init(serverPublicHashKeys: [CommonNetworking.AuthenticationHandler.publicKeyHash(of: leaf) ?? ""])
        }
        XCTAssertTrue(accepted, "Matching public key pin must be accepted")

        let wrongPin = Data(repeating: 7, count: 32).base64EncodedString()
        let rejected = try await request(url) { _ in .init(serverPublicHashKeys: [wrongPin]) }
        XCTAssertFalse(rejected, "A wrong public key pin must be rejected")
    }

    func test_authenticationHandlerWithCertPath() async throws {
        let url = CommonNetworking.AuthenticationHandler.Server.googleUkWithCertPath.url
        let dir = FileManager.default.temporaryDirectory
        var files = [URL]()
        defer { files.forEach { try? FileManager.default.removeItem(at: $0) } }

        let accepted = try await request(url) { leaf in
            let path = dir.appendingPathComponent("\(UUID().uuidString).cer")
            try? (SecCertificateCopyData(leaf) as Data).write(to: path)
            files.append(path)
            return .init(pathToCertificates: [path.path])
        }
        XCTAssertTrue(accepted, "Matching pinned certificate must be accepted")

        let badPath = dir.appendingPathComponent("\(UUID().uuidString).cer")
        try Data(repeating: 1, count: 64).write(to: badPath)
        files.append(badPath)
        let rejected = try await request(url) { _ in .init(pathToCertificates: [badPath.path]) }
        XCTAssertFalse(rejected, "A different certificate must be rejected")
    }
}
