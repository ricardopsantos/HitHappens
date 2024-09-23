//
//  ___Template___ViewModel.swift
//  Common
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

public struct ___Template___Model: Equatable, Hashable, Sendable {
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

extension ___Template___ViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case increment
        case displayRandomError
    }

    struct Dependencies {
        let model: ___Template___Model
        let onCompletion: (String) -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class ___Template___ViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var message: String = ""
    @Published var counter: Int = 0
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.message = dependencies.model.message
        self.counter = dependencies.model.counter
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        case .increment: ()
            counter += 1
            message = "Counter: \(counter)"
        case .displayRandomError:
            alertModel = .init(
                type: .error,
                location: .top,
                message: String.randomWithSpaces(10)
            )
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension ___Template___ViewModel {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    ___Template___ViewCoordinator(presentationStyle: .fullScreenCover, haveNavigationStack: false, model: .init(message: "Hi"))
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
