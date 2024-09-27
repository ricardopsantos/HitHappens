//
//  RootViewModel.swift
//  HitHappens
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

    init(isAppStartCompleted: Bool = false) {
        self.isAppStartCompleted = isAppStartCompleted
    }
}

extension RootViewModel {
    enum Actions {
        case reload
        case start
        case markOnboardingAsCompleted
    }

    struct Dependencies {
        let model: RootModel
        let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
        let dataBaseRepository: DataBaseRepositoryProtocol
        let cloudKitService: CloudKitServiceProtocol
    }
}

@MainActor
class RootViewModel: ObservableObject {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var alertModel: Model.AlertModel?
    @Published private(set) var isAppStartCompleted: Bool = false
    @Published private(set) var isOnboardingCompleted: Bool = false
    private var cancelBag = CancelBag()
    private var nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    private var dataBaseRepository: DataBaseRepositoryProtocol
    private var cloudKitService: CloudKitServiceProtocol
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.nonSecureAppPreferences = dependencies.nonSecureAppPreferences
        self.cloudKitService = dependencies.cloudKitService
        self.isAppStartCompleted = dependencies.model.isAppStartCompleted
        startListening()
    }

    // MARK: - Functions

    func send(action: Actions) {
        switch action {
        case .reload:
            isAppStartCompleted = true
            isOnboardingCompleted = nonSecureAppPreferences?.isOnboardingCompleted ?? false
        case .start:
            send(action: .reload)
        case .markOnboardingAsCompleted:
            guard !isOnboardingCompleted else { return }
            nonSecureAppPreferences?.isOnboardingCompleted = true
            // isOnboardingCompleted = true
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension RootViewModel {
    func startListening() {

        nonSecureAppPreferences?.output([]).sinkToReceiveValue { [weak self] some in
            guard let self = self else { return }
            switch some {
            case .success(let some):
                switch some {
                case .deletedAll, .changedKey:
                    let operationId = "\(Self.self)|\(#function)"
                    Common.ExecutionControlManager.debounce(operationId: operationId) { [weak self] in
                        Common_Utils.delay { [weak self] in
                            guard let self = self else { return }
                            self.send(action: .reload)
                        }
                    }
                }
            }
        }.store(in: cancelBag)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    RootViewCoordinator(presentationStyle: .fullScreenCover)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
