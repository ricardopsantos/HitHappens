//
//  SettingsViewModel.swift
//  HitHappens
//
//  Created by Ricardo Santos on 03/01/24.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

//
// MARK: - Model
//

struct SettingsModel: Equatable, Hashable, Sendable {
    let some: Bool
    init(some: Bool = false) {
        self.some = some
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension SettingsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case shouldDisplayOnboarding
        case fetchAppVersion
    }

    struct Dependencies {
        let model: SettingsModel
        let onShouldDisplayPublicCode: (String) -> Void
        let appConfigService: AppConfigServiceProtocol
        let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
        let cloudKitService: CloudKitServiceProtocol
    }
}

class SettingsViewModel: BaseViewModel {
    // MARK: - View Usage Attributes
    private var cancelBag = CancelBag()
    @Published var supportEmail: String = ""
    @Published var publicCodeURL: String = ""
    @Published var appVersionInfo: String = ""
    private var appVersion: Model.AppVersion?
    private var nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    private var cloudKitService: CloudKitServiceProtocol?
    private var appConfigService: AppConfigServiceProtocol?
    public init(dependencies: Dependencies) {
        self.nonSecureAppPreferences = dependencies.nonSecureAppPreferences
        self.appConfigService = dependencies.appConfigService
        self.cloudKitService = dependencies.cloudKitService
        super.init()
    }

    func send(action: Actions) {
        switch action {
        case .didAppear:
            send(action: .fetchAppVersion)
            Task { [weak self] in
                guard let self = self else { return }
                loadingModel = .loading(message: "")
                do {
                    let appConfigService = try await appConfigService?.requestAppConfig(
                        .init(),
                        cachePolicy: .cacheElseLoad
                    )
                    supportEmail = appConfigService?.hitHappens.supportEmailEncrypted.decrypted ?? ""
                    publicCodeURL = appConfigService?.hitHappens.publicCodeURL ?? ""
                } catch {
                    handle(error: error, sender: "\(action)")
                }
                loadingModel = .notLoading
            }

        case .didDisappear: ()
        case .shouldDisplayOnboarding:
            nonSecureAppPreferences?.isOnboardingCompleted = false
        case .fetchAppVersion:
            Task { [weak self] in
                guard let self = self else { return }
                let version = await cloudKitService?.fetchAppVersion()
                guard let version = version else { return }
                let appVersion = Common.AppInfo.version.split(by: " ").first?.description ?? ""
                let result = self.compareVersions(appVersion, version.storeVersion)
                switch result {
                case .orderedAscending:
                    appVersionInfo = "!! Your app needs to be updated !!".localizedMissing
                case .orderedDescending:
                    appVersionInfo = ""
                case .orderedSame:
                    appVersionInfo = "(You app is updated)".localizedMissing
                }
                self.appVersion = version
            }
        }
    }
}

private extension SettingsViewModel {
    func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult {
        let components1 = version1.split(separator: ".").compactMap { Int($0) }
        let components2 = version2.split(separator: ".").compactMap { Int($0) }
        for (v1, v2) in zip(components1, components2) {
            if v1 < v2 {
                return .orderedAscending
            } else if v1 > v2 {
                return .orderedDescending
            }
        }

        if components1.count < components2.count {
            return .orderedAscending
        } else if components1.count > components2.count {
            return .orderedDescending
        }

        return .orderedSame
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    SettingsViewCoordinator(presentationStyle: .notApplied)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
