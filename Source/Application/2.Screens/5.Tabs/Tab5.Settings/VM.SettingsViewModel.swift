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
    }

    struct Dependencies {
        let model: SettingsModel
        let onShouldDisplayPublicCode: (String) -> Void
        let appConfigService: AppConfigServiceProtocol
        let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    }
}

class SettingsViewModel: BaseViewModel {
    // MARK: - View Usage Attributes
    private var cancelBag = CancelBag()
    @Published var supportEmail: String = ""
    @Published var publicCodeURL: String = ""
    private var nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    private var appConfigService: AppConfigServiceProtocol?
    public init(dependencies: Dependencies) {
        self.nonSecureAppPreferences = dependencies.nonSecureAppPreferences
        self.appConfigService = dependencies.appConfigService
        super.init()
    }

    func send(action: Actions) {
        switch action {
        case .didAppear:
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
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    SettingsViewCoordinator(presentationStyle: .notApplied)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
