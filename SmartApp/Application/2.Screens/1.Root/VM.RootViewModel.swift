//
//  RootViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

struct RootModel: Equatable, Hashable, Sendable {
    let isAppStartCompleted: Bool
    let isOnboardingCompleted: Bool

    init(
        isAppStartCompleted: Bool = false,
        isOnboardingCompleted: Bool = false
    ) {
        self.isAppStartCompleted = isAppStartCompleted
        self.isOnboardingCompleted = isOnboardingCompleted
    }
}

extension RootViewModel {
    enum Actions {
        case start
        case onboardingCompleted
    }

    struct Dependencies {
        let model: RootModel
        let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    }
}

@MainActor
class RootViewModel: ObservableObject {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var alertModel: Model.AlertModel?
    @Published private(set) var isAppStartCompleted: Bool = false
    @Published private(set) var isOnboardingCompleted: Bool = false
    @Published private(set) var preferencesChanged: Date = .now
    private var cancelBag = CancelBag()
    private var nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    public init(dependencies: Dependencies) {
        self.nonSecureAppPreferences = dependencies.nonSecureAppPreferences
        self.isAppStartCompleted = dependencies.model.isAppStartCompleted
        self.isOnboardingCompleted = dependencies.model.isOnboardingCompleted
        dependencies.nonSecureAppPreferences.output([]).sinkToReceiveValue { [weak self] _ in
            self?.preferencesChanged = .now
        }.store(in: cancelBag)
    }

    // MARK: - Functions

    func send(action: Actions) {
        switch action {
        case .start:
            guard !isAppStartCompleted else { return }
            isAppStartCompleted = true
        case .onboardingCompleted:
            guard !isOnboardingCompleted else { return }
            nonSecureAppPreferences?.isOnboardingCompleted = true
            isOnboardingCompleted = true
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension RootViewModel {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    RootViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
