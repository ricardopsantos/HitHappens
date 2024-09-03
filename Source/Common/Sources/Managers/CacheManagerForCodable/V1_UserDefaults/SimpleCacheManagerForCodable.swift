//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

//
// MARK: - CacheManagerForCodableUserDefaultsRepository
//

public extension Common {
    class CacheManagerForCodableUserDefaultsRepository: CodableCacheManagerProtocol {
        private init() {}
        public static let shared = CacheManagerForCodableUserDefaultsRepository()

        //
        // MARK: - Sync
        //
        public func syncStore(
            _ codable: some Codable,
            key: String,
            params: [any Hashable],
            timeToLiveMinutes: Int? = nil
        ) {
            let expiringCodableObjectWithKey = Commom_ExpiringKeyValueEntity(
                codable,
                key: key,
                params: params,
                timeToLiveMinutes: timeToLiveMinutes
            )
            if let data = try? JSONEncoder().encode(expiringCodableObjectWithKey) {
                Common.InternalUserDefaults.defaults?.set(
                    data,
                    forKey: expiringCodableObjectWithKey.key
                )
                Common.InternalUserDefaults.defaults?.synchronize()
            } else {
                Common_Utils.assert(false, message: "Not predicted")
            }
        }

        public func syncRetrieve<T: Codable>(_ type: T.Type, key: String, params: [any Hashable]) -> (model: T, recordDate: Date)? {
            guard let data = Common.InternalUserDefaults.defaults?.data(forKey: Commom_ExpiringKeyValueEntity.composedKey(key, params)),
                  let expiringCodableObjectWithKey = try? JSONDecoder().decodeFriendly(Common.ExpiringKeyValueEntity.self, from: data),
                  let cachedRecord = expiringCodableObjectWithKey.extract(type) else {
                return nil
            }
            return (cachedRecord, expiringCodableObjectWithKey.recordDate)
        }

        public func syncAllCachedKeys() -> [(String, Date)] {
            let keys = Common.InternalUserDefaults.defaults?.dictionaryRepresentation().keys.filter { $0.hasPrefix(Common.InternalUserDefaults.Keys.expiringKeyValueEntity.defaultsKey) } ?? []
            var result: [(String, Date)] = []
            keys.forEach { key in
                if let data = Common.InternalUserDefaults.defaults?.data(forKey: key) {
                    if let expiringCodableObjectWithKey = try? JSONDecoder().decodeFriendly(Common.ExpiringKeyValueEntity.self, from: data) {
                        result.append((key, expiringCodableObjectWithKey.recordDate))
                    }
                }
            }
            return result
        }

        public func syncClearAll() {
            let keys = Common.InternalUserDefaults.defaults?.dictionaryRepresentation().keys.filter { $0.hasPrefix(Common.InternalUserDefaults.Keys.expiringKeyValueEntity.defaultsKey) } ?? []
            keys.forEach { key in
                Common.InternalUserDefaults.defaults?.removeObject(forKey: key)
            }
            Common.InternalUserDefaults.defaults?.synchronize()
        }

        //
        // MARK: - Async
        //
        public func aSyncStore<T: Codable>(_ codable: T, key: String, params: [any Hashable], timeToLiveMinutes: Int?) async {
            try? await withCheckedThrowingContinuation { continuation in
                syncStore(codable, key: key, params: params, timeToLiveMinutes: timeToLiveMinutes)
                continuation.resume()
            }
        }

        public func aSyncRetrieve<T: Codable>(_ type: T.Type, key: String, params: [any Hashable]) async -> (model: T, recordDate: Date)? {
            try? await withCheckedThrowingContinuation { continuation in
                let result = syncRetrieve(type, key: key, params: params)
                continuation.resume(with: .success(result))
            }
        }

        public func aSyncClearAll() async {
            try? await withCheckedThrowingContinuation { continuation in
                syncClearAll()
                continuation.resume()
            }
        }

        public func aSyncAllCachedKeys() async -> [(String, Date)] {
            do {
                return try await withCheckedThrowingContinuation { continuation in
                    let result = syncAllCachedKeys()
                    continuation.resume(with: .success(result))
                }
            } catch {}
            return []
        }
    }
}