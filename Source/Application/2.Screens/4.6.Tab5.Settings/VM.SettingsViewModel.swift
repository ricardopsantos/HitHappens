//
//  SettingsViewModel.swift
//  SmartApp
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
        let onShouldDisplayEditUserDetails: () -> Void
        let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    }
}

class SettingsViewModel: BaseViewModel {
    // MARK: - View Usage Attributes
    private var cancelBag = CancelBag()
    private var nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    public init(dependencies: Dependencies) {
        self.nonSecureAppPreferences = dependencies.nonSecureAppPreferences
        super.init()
    }

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
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
    SettingsViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
