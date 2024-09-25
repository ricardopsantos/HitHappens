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
                cloudKitService: DependenciesManager.Services.cloudKitService,
                dataBaseRepository: DependenciesManager.Repository.dataBaseRepository,
                nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
                secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
            )
        } else {
            config = .init(
                appConfigService: DependenciesManager.Services.appConfigService,
                cloudKitService: DependenciesManager.Services.cloudKitService,
                dataBaseRepository: DependenciesManager.Repository.dataBaseRepository,
                nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
                secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
            )
        }
        configuration = config
        delegate.configuration = config
        //
        // Modules Setup
        //
        SetupManager.shared.setup(
            dataBaseRepository: config.dataBaseRepository,
            nonSecureAppPreferences: config.nonSecureAppPreferences,
            cloudKitService: config.cloudKitService
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
