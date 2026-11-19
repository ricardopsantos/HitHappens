//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
//
// https://betterprogramming.pub/mastering-thread-safety-in-swift-with-one-runtime-trick-260c358a7515
//
public extension Common_PropertyWrappers {
    /**
     The property wrapper ensures that access to its internal value is synchronized.
     It uses an instance of Common.UnfairLockManager to provide mutual exclusion, preventing data races and ensuring thread safety.
     */
    @propertyWrapper
    final class ThreadSafeUnfairLock<T> {
        private let lock = Common.UnfairLockThreadingManager()
        private var value: T

        public init(wrappedValue: T) {
            self.value = wrappedValue
        }

        public var projectedValue: ThreadSafeUnfairLock<T> { self }

        // swiftlint:disable implicit_getter
        public var wrappedValue: T {
            get {
                lock.lock(); defer { self.lock.unlock() }
                return value
            }
            _modify {
                self.lock.lock(); defer { self.lock.unlock() }
                yield &self.value
            }
        }

        // swiftlint:enable implicit_getter

        public func read<V>(_ f: (T) -> V) -> V {
            lock.lock(); defer { self.lock.unlock() }
            return f(value)
        }

        @discardableResult
        public func write<V>(_ f: (inout T) -> V) -> V {
            lock.lock(); defer { self.lock.unlock() }
            return f(&value)
        }
    }
}

public extension Common_PropertyWrappers {
    /**
     The property wrapper ensures that access to its underlying value is synchronized,
     preventing concurrent read and write operations from causing data races or inconsistent states.
     It guards the value with an NSLock to manage thread safety.

     Reads and writes are atomic, and so are read-modify-write operations such as `value += 1`
     (they go through `_modify`, which holds the lock for the whole mutation). A plain
     get/set pair is NOT enough for those: two threads can both read the old value and
     both write back old + 1, losing an update.
     */
    @propertyWrapper
    struct ThreadSafeDispatchQueue<T> {
        // Reference type: copies of the wrapper (it is a struct) all share the same lock.
        private let lock = NSLock()
        private var objectValue: T!

        public init(wrappedValue value: T) {
            self.objectValue = value
        }

        /// The underlying value wrapped by the bindable state.
        // swiftlint:disable implicit_getter
        public var wrappedValue: T {
            get {
                lock.lock(); defer { lock.unlock() }
                return objectValue
            }
            set {
                lock.lock(); defer { lock.unlock() }
                objectValue = newValue
            }
            _modify {
                lock.lock(); defer { lock.unlock() }
                yield &objectValue
            }
        }
        // swiftlint:enable implicit_getter
    }
}
