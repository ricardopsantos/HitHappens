//
//  LaunchApp.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import CloudKit
//
import Domain
import Common
import DesignSystem

struct HitHappensApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let configuration: ConfigurationViewModel
    /// Root of the router chain. Top-level coordinators resolve their
    /// `@EnvironmentObject var parentCoordinator: RouterViewModel` against this.
    /// (RouterViewModel is deliberately ObservableObject, not @Observable — see
    /// RouterViewModel.swift for why.)
    let rootRouter = RouterViewModel()
    init() {
        //
        // Security
        //
        CPPWrapper.disable_gdb() // Detach debugger for real device
        CPPWrapper.crash_if_debugged() // Crash app if debugger Detach failed
        //
        // iCloud availability must be resolved before DataBaseRepository.shared is first
        // accessed, because the persistence container type (NSPersistentCloudKitContainer
        // vs NSPersistentContainer) is fixed at init time. ubiquityIdentityToken is a
        // synchronous, zero-cost check: nil means no iCloud account is active on this device.
        //
        Domain.coreDataPersistence = .default(
            iCloudEnabled: FileManager.default.ubiquityIdentityToken != nil
        )
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
        self.configuration = config
        delegate.configuration = config
        // Suppress real analytics events during UI tests
        if UITestingManager.Options.onUITesting.enabled {
            delegate.analyticsManager = NullAnalyticsManager()
        }
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
                .environment(configuration)
                .environmentObject(rootRouter)
        }
    }
}
