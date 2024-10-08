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
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

class MainTabViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published var selectedTab: AppTab = .tab1
    private var dataBaseRepository: DataBaseRepositoryProtocol?
    private let cancelBag: CancelBag = .init()
    public init(dependencies: Dependencies) {
        super.init()
        self.selectedTab = dependencies.model.selectedTab
        self.dataBaseRepository = dependencies.dataBaseRepository
        startListeningEvents()
    }

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
private extension MainTabViewModel {
    func startListeningEvents() {
        dataBaseRepository?.output([]).sink { some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseReloaded: ()
                case .databaseDidInsertedContentOn: ()
                case .databaseDidUpdatedContentOn: ()
                case .databaseDidDeletedContentOn: ()
                case .databaseDidChangedContentItemOn: ()
                case .databaseDidFinishChangeContentItemsOn: ()
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
    MainTabViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
