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
        //
        // Security
        //
        CPPWrapper.disable_gdb() // Detach debugger for real device
        CPPWrapper.crash_if_debugged() // Crash app if debugger Detach failed
        //
        // Dependencies Setup
        //
        let config: ConfigurationViewModel!
        if UITestingManager.Options.onUITesting.enabled {
            config = .init(
                appConfigService: DependenciesManager.Services.appConfigServiceMock,
                dataBaseRepository: DependenciesManager.Repository.dataBaseRepository,
                nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
                secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
            )
            self.configuration = config
        } else {
            config = .init(
                appConfigService: DependenciesManager.Services.appConfigService,
                dataBaseRepository: DependenciesManager.Repository.dataBaseRepository,
                nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
                secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
            )
            self.configuration = config
        }
        //
        // Modules Setup
        //
        SetupManager.shared.setup(
            dataBaseRepository: config.dataBaseRepository,
            nonSecureAppPreferences: config.nonSecureAppPreferences
        )
    }

    var body: some Scene {
        WindowGroup {
            RootViewCoordinator(presentationStyle: .fullScreenCover)
                .onAppear(perform: {
                    InterfaceStyleManager.setup(nonSecureAppPreferences: configuration.nonSecureAppPreferences)
                })
                .environmentObject(configuration)
        }
    }
}
