//
//  LaunchApp.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Domain
import Common
import DesignSystem

struct HitHappensApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let configuration: ConfigurationViewModel
    init() {
        let sampleService = DependenciesManager.Services.sampleService
        let dataBaseRepository = DependenciesManager.Repository.dataBaseRepository
        let nonSecureAppPreferences = DependenciesManager.Repository.nonSecureAppPreferences
        let secureAppPreferences = DependenciesManager.Repository.secureAppPreferences
        let config: ConfigurationViewModel!
        let onTesting = UITestingManager.Options.onUITesting.enabled || Common_Utils.onUnitTests
        if onTesting {
            config = .init(
                sampleService: sampleService,
                appConfigService: DependenciesManager.Services.appConfigServiceMock,
                dataBaseRepository: dataBaseRepository,
                nonSecureAppPreferences: nonSecureAppPreferences,
                secureAppPreferences: secureAppPreferences
            )
            self.configuration = config
        } else {
            config = .init(
                sampleService: sampleService,
                appConfigService: DependenciesManager.Services.appConfigService,
                dataBaseRepository: dataBaseRepository,
                nonSecureAppPreferences: nonSecureAppPreferences,
                secureAppPreferences: secureAppPreferences
            )
            self.configuration = config
        }
        SetupManager.shared.setup(dataBaseRepository: dataBaseRepository)
        InterfaceStyleManager.setup(nonSecureAppPreferences: configuration.nonSecureAppPreferences)
    }

    var body: some Scene {
        WindowGroup {
            RootViewCoordinator()
                .onAppear(perform: {
                    InterfaceStyleManager.setup(nonSecureAppPreferences: configuration.nonSecureAppPreferences)
                })
                .environmentObject(configuration)
        }
    }
}
