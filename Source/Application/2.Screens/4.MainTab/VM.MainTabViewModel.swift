//
//  MainTabViewModel.swift
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

struct MainTabModel: Equatable, Hashable, Sendable {
    let selectedTab: AppTab

    init(selectedTab: AppTab) {
        self.selectedTab = selectedTab
    }
}

//
// MARK: - ViewModel Builder
//

extension MainTabViewModel {
    enum Actions {
        case didAppear
        case didDisappear
    }

    struct Dependencies {
        let model: MainTabModel
    }
}

class MainTabViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published var selectedTab: AppTab = .tab1
    public init(dependencies: Dependencies) {
        self.selectedTab = dependencies.model.selectedTab
    }

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    MainTabViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif