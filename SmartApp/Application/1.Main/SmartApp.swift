//
//  LaunchApp.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Domain
import Common
import DesignSystem

// @main
struct SmartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let configuration: ConfigurationViewModel
    let appState: AppStateViewModel
    init() {
        let userService = DependenciesManager.Services.userService
        let sampleService = DependenciesManager.Services.sampleService
        let userRepository = DependenciesManager.Repository.userRepository
        let dataBaseRepository = DependenciesManager.Repository.dataBaseRepository
        let nonSecureAppPreferences = DependenciesManager.Repository.nonSecureAppPreferences
        let secureAppPreferences = DependenciesManager.Repository.secureAppPreferences
        let config: ConfigurationViewModel!
        let onTesting = UITestingManager.Options.onUITesting.enabled || Common_Utils.onUnitTests
        if onTesting {
            config = .init(
                userService: userService,
                sampleService: sampleService,
                dataUSAService: DependenciesManager.Services.dataUSAServiceMock,
                dataBaseRepository: dataBaseRepository,
                userRepository: userRepository,
                nonSecureAppPreferences: nonSecureAppPreferences,
                secureAppPreferences: secureAppPreferences
            )
            self.configuration = config
        } else {
            config = .init(
                userService: userService,
                sampleService: sampleService,
                dataUSAService: DependenciesManager.Services.dataUSAService,
                dataBaseRepository: dataBaseRepository,
                userRepository: userRepository,
                nonSecureAppPreferences: nonSecureAppPreferences,
                secureAppPreferences: secureAppPreferences
            )
            self.configuration = config
        }
        SetupManager.shared.setup(dataBaseRepository: dataBaseRepository)
        self.appState = .init()
    }

    var body: some Scene {
        WindowGroup {
            RootViewCoordinator()
                .onAppear(perform: {
                    InterfaceStyleManager.setup(nonSecureAppPreferences: configuration.nonSecureAppPreferences)
                })
                .environmentObject(appState)
                .environmentObject(configuration)
        }
    }
}
