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
        public static var cloudKitService: CloudKitServiceProtocol {
            let service = CloudKitService(cloudKit: AppConstants.cloudKitId)
            service.dataBaseRepository = Repository.dataBaseRepository
            return service
        }

        public static var appConfigService: AppConfigServiceProtocol {
            AppConfigService(
                webAPI: WebAPI.webAPI,
                dataBaseRepository: Repository.dataBaseRepository
            )
        }
    }

    public enum Repository {
        public static var dataBaseRepository: DataBaseRepositoryProtocol {
            Domain.coreDataPersistence = .appGroup(
                identifier: AppConstants.appGroup,

                iCloudEnabled: true
            )
            return DataBaseRepository.shared
        }

        public static var secureAppPreferences: SecureAppPreferencesProtocol { SecureAppPreferences.shared }
        public static var nonSecureAppPreferences: NonSecureAppPreferencesProtocol { NonSecureAppPreferences.shared }
    }
}
