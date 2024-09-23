//
//  SplashViewModel.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Common

struct SplashModel: Equatable, Hashable, Sendable {
    let some: Bool
    public init(some: Bool = true) {
        self.some = some
    }
}

extension SplashViewModel {
    enum Actions {
        case didAppear
        case didDisappear
    }

    struct Dependencies {
        let model: SplashModel?
        let onCompletion: () -> Void
    }
}

class SplashViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    public init(dependencies: Dependencies) {}

    // MARK: - Functions

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
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
    SplashViewCoordinator(presentationStyle: .notApplied, onCompletion: {})
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
