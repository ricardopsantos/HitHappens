//
//  OnBoardingViewModel.swift
//  HitHappens
//
//  Created by Ricardo Santos on 20/05/2024.
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

public struct OnboardingModel: Equatable, Hashable, Sendable {
    let message: String
    let counter: Int

    init(message: String = "", counter: Int = 0) {
        self.message = message
        self.counter = counter
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension OnboardingViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case fetchConfig
    }

    struct Dependencies {
        let model: OnboardingModel
        let onCompletion: (String) -> Void
        let appConfigService: AppConfigServiceProtocol
    }
}

class OnboardingViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var message: String = ""
    @Published var counter: Int = 0
    private let appConfigService: AppConfigServiceProtocol?
    public init(dependencies: Dependencies) {
        self.appConfigService = dependencies.appConfigService
        self.message = dependencies.model.message
        self.counter = dependencies.model.counter
    }

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        case .fetchConfig: () // Do something
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension OnboardingViewModel {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    OnboardingViewCoordinator(haveNavigationStack: true, model: .init(), onCompletion: { _ in })
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
