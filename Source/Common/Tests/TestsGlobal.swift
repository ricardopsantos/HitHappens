//
//  File.swift
//
//
//  Created by Ricardo Santos on 23/07/2024.
//

import Foundation

import XCTest
import Combine
import Common

internal class CommonBundleFinder {}

public struct ResponseDto {
    private init() {}
}

public struct RequestDto {
    private init() {}
}

public enum TestsGlobal {
    static let cancelBag = CancelBag()
    static var timeout: Int = 5
    static var loadedAny: Any?
    static var bundleIdentifier: String {
        Bundle(for: CommonBundleFinder.self).bundleIdentifier ?? ""
    }
}

func waitUntil(_ timeout: TimeInterval = 5, condition: @escaping () -> Bool) {
    let predicate = NSPredicate { _, _ in condition() }
    let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
    _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
}

func averageOperationTime(
    iterations: Int,
    precondition: () -> Void,
    operation: () -> Void,
    onComplete: (Double) -> Void
) {
    var timeElapsed: Double = 0
    for _ in 1...iterations {
        precondition()
        timeElapsed += Common_CronometerManager.measure {
            operation()
        }
    }
    let average = timeElapsed / Double(iterations)
    onComplete(average)
}
