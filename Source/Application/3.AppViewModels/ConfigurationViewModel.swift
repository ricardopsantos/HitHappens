//
//  Configuration.swift
//  HitHappens
//
//  Created by Ricardo Santos on 19/07/2024.
//

import Foundation
//
import Domain
import Core

// ConfigurationViewModel is `ObservableObject` so that we can inject it on the view hierarchy
@MainActor
class ConfigurationViewModel: ObservableObject {
    // MARK: - Dependency Attributes

    // Services
    let appConfigService: AppConfigServiceProtocol
    let cloudKitService: CloudKitServiceProtocol

    // Repositories
    let dataBaseRepository: DataBaseRepositoryProtocol
    let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    let secureAppPreferences: SecureAppPreferencesProtocol

    // ViewModels
    // let authenticationViewModel: AuthenticationViewModel

    init(
        appConfigService: AppConfigServiceProtocol,
        cloudKitService: CloudKitServiceProtocol,
        dataBaseRepository: DataBaseRepositoryProtocol,
        nonSecureAppPreferences: NonSecureAppPreferencesProtocol,
        secureAppPreferences: SecureAppPreferencesProtocol
    ) {
        self.appConfigService = appConfigService
        self.cloudKitService = cloudKitService
        self.dataBaseRepository = dataBaseRepository
        self.nonSecureAppPreferences = nonSecureAppPreferences
        self.secureAppPreferences = secureAppPreferences
    }
}

// MARK: - Previews

extension ConfigurationViewModel {
    static var defaultForPreviews: ConfigurationViewModel {
        ConfigurationViewModel(
            appConfigService: DependenciesManager.Services.appConfigServiceMock,
            cloudKitService: DependenciesManager.Services.cloudKitService,
            dataBaseRepository: DependenciesManager.Repository.dataBaseRepository,
            nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
            secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
        )
    }
}
