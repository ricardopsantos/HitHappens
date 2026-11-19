//
//  Created by Ricardo Santos on 12/08/2024.
//

import XCTest
import Foundation
import Combine
//
@testable import Common

final class UnfairLockManager_Tests: XCTestCase {
    let lockManager = Common.UnfairLockThreadingManager()

    func testLockUnlock() {
        var value = 0
        lockManager.lock()
        value += 1
        XCTAssert(value == 1)
        lockManager.unlock()
    }

    func testTryLock() {
        var value = 0
        XCTAssert(lockManager.tryLock())
        value += 1
        XCTAssert(value == 1)
        lockManager.unlock()
    }

    func testExecute() {
        var value = 0
        let result = lockManager.execute {
            value += 1
            return value
        }
        XCTAssert(result == 1)
        XCTAssert(value == 1)
    }

    func testTryExecute() {
        var value = 0
        do {
            let result = try lockManager.tryExecute {
                value += 1
                return value
            }
            XCTAssert(result == 1)
            XCTAssert(value == 1)
        } catch {
            XCTFail("tryExecute threw an unexpected error: \(error)")
        }
    }

    func testTryExecuteThrowsError() {
        enum TestError: Error {
            case intentionalError
        }

        do {
            _ = try lockManager.tryExecute {
                throw TestError.intentionalError
            }
            XCTFail("Expected tryExecute to throw an error")
        } catch TestError.intentionalError {
            // Success: Correct error was thrown
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // Perform 1000 writes concurrently
    func testThreadSafety() {
        var value = 0
        let iterations = 1000
        let expectation = XCTestExpectation(description: #function)
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            lockManager.execute {
                value += 1
            }
        }
        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssert(value == iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_highContentionWithMultipleLocks() {
        var value = 0
        let iterations = 10_000
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: #function, attributes: .concurrent)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                self.lockManager.lock()
                value += 1
                self.lockManager.unlock()
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(value, iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_deadlockPrevention() {
        let expectation = XCTestExpectation(description: #function)

        let queue1 = DispatchQueue(label: "com.test.queue1")
        let queue2 = DispatchQueue(label: "com.test.queue2")

        // os_unfair_lock is owned by the thread that locked it: unlocking from another thread
        // aborts the process. So the holder must lock, hold and unlock on the SAME thread.
        queue1.async {
            self.lockManager.lock()
            Thread.sleep(forTimeInterval: 0.1)
            self.lockManager.unlock()
        }

        // The second thread tries to lock while the first still holds it: it must block until
        // the first unlocks, then get the lock (i.e. no deadlock).
        queue2.asyncAfter(deadline: .now() + 0.05) {
            self.lockManager.lock()
            self.lockManager.unlock()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_stressTestWithLargeNumberOfOperations() {
        var value = 0
        let iterations = 100_000
        let expectation = XCTestExpectation(description: #function)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            lockManager.execute {
                value += 1
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(value, iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_concurrentExecutionWithDelays() {
        var value = 0
        let iterations = 100
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: "delayedExecutionQueue", attributes: .concurrent)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                self.lockManager.execute {
                    let currentValue = value
                    Thread.sleep(forTimeInterval: 0.01)
                    value = currentValue + 1
                }
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(value, iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    /// Counters are mutated from many threads, so they get their own lock (the lock under test
    /// only guards `tryLock`). Completion is awaited with a DispatchGroup, not a fixed sleep.
    func test_highContentionWithTryLock() {
        var successCount = 0
        var failureCount = 0
        let counterLock = NSLock()
        let iterations = 10_000
        let group = DispatchGroup()

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            group.enter()
            DispatchQueue.global().async {
                let acquired = self.lockManager.tryLock()
                if acquired {
                    self.lockManager.unlock()
                }
                counterLock.lock()
                if acquired { successCount += 1 } else { failureCount += 1 }
                counterLock.unlock()
                group.leave()
            }
        }

        XCTAssertEqual(group.wait(timeout: .now() + TimeInterval(TestsGlobal.timeout)), .success)
        XCTAssertEqual(successCount + failureCount, iterations)
        XCTAssertGreaterThan(successCount, 0)
    }

    func test_simultaneousReadsAndWritesWithLock() {
        var value = 0
        let iterations = 1_000
        let resultsLock = NSLock()
        var readResults = [Int]()
        let group = DispatchGroup()

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            group.enter()
            DispatchQueue.global().async {
                self.lockManager.lock()
                value += 1
                let readValue = value
                self.lockManager.unlock()

                resultsLock.lock()
                readResults.append(readValue)
                resultsLock.unlock()
                group.leave()
            }
        }

        XCTAssertEqual(group.wait(timeout: .now() + TimeInterval(TestsGlobal.timeout)), .success)
        XCTAssertEqual(readResults.count, iterations)
        XCTAssertEqual(value, iterations)
        // Every increment happened exactly once under the lock, so each read is unique: 1...iterations.
        XCTAssertEqual(Set(readResults), Set(1...iterations))
    }
}
