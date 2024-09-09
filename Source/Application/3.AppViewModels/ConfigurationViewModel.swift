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
    let sampleService: SampleServiceProtocol

    // Repositories
    let dataBaseRepository: DataBaseRepositoryProtocol
    let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    let secureAppPreferences: SecureAppPreferencesProtocol

    // ViewModels
    // let authenticationViewModel: AuthenticationViewModel

    // MARK: - Usage/Auxiliar Attributes
    // private var cancelBag: CancelBag = .init()

    // MARK: - Constructor
    init(
        sampleService: SampleServiceProtocol,
        appConfigService: AppConfigServiceProtocol,
        dataBaseRepository: DataBaseRepositoryProtocol,
        nonSecureAppPreferences: NonSecureAppPreferencesProtocol,
        secureAppPreferences: SecureAppPreferencesProtocol
    ) {
        self.sampleService = sampleService
        self.appConfigService = appConfigService
        self.dataBaseRepository = dataBaseRepository
        self.nonSecureAppPreferences = nonSecureAppPreferences
        self.secureAppPreferences = secureAppPreferences
    }
}

// MARK: - Previews

extension ConfigurationViewModel {
    static var defaultForPreviews: ConfigurationViewModel {
        ConfigurationViewModel(
            sampleService: DependenciesManager.Services.sampleService,
            appConfigService: DependenciesManager.Services.appConfigServiceMock,
            dataBaseRepository: DependenciesManager.Repository.dataBaseRepository,
            nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
            secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
        )
    }

    static var defaultForApp: ConfigurationViewModel {
        ConfigurationViewModel(
            sampleService: DependenciesManager.Services.sampleService,
            appConfigService: DependenciesManager.Services.appConfigService,
            dataBaseRepository: DependenciesManager.Repository.dataBaseRepository,
            nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
            secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
        )
    }
}
