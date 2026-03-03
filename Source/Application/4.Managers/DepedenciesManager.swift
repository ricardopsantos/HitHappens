//
//  CoreProtocolsResolved.swift
//  HitHappens
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation
//
import Domain
import Core
import Common

public class DependenciesManager {
    private init() {}
    enum WebAPI {
        public static var webAPI: NetworkManagerProtocol { NetworkManagerV2.shared }
    }

    enum Services {
        public static var appConfigServiceMock: AppConfigServiceProtocol { AppConfigServiceMock.shared }
        /// Stable singleton – creating a new instance per call would discard the internal cache.
        public static let cloudKitService: CloudKitServiceProtocol = CloudKitService(cloudKit: AppConstants.cloudKitId)
        /// Stable singleton – `AppConfigService` owns a `cacheManager`; a new instance per call
        /// would silently discard cached responses and re-insert default events on first login.
        public static let appConfigService: AppConfigServiceProtocol = AppConfigService(
            webAPI: WebAPI.webAPI,
            dataBaseRepository: Repository.dataBaseRepository
        )
    }

    public enum Repository {
        public static var dataBaseRepository: DataBaseRepositoryProtocol { DataBaseRepository.shared }
        public static var secureAppPreferences: SecureAppPreferencesProtocol { SecureAppPreferences.shared }
        public static var nonSecureAppPreferences: NonSecureAppPreferencesProtocol { NonSecureAppPreferences.shared }
    }
}
