//
//  CoreProtocolsResolved.swift
//  SmartApp
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
    enum Services {
        public static var appConfigServiceMock: AppConfigServiceProtocol { AppConfigServiceMock.shared }
        public static var appConfigService: AppConfigServiceProtocol { AppConfigService.shared }
        public static var sampleService: SampleServiceProtocol { SampleService.shared }
    }

    public enum Repository {
        public static var dataBaseRepository: DataBaseRepositoryProtocol { DataBaseRepository.shared }
        public static var secureAppPreferences: SecureAppPreferencesProtocol { SecureAppPreferences.shared }
        public static var nonSecureAppPreferences: NonSecureAppPreferencesProtocol { NonSecureAppPreferences.shared }
    }
}
