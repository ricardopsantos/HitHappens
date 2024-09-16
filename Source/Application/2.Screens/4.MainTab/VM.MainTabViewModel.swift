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
        startListeningDBChanges()
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
    func startListeningDBChanges() {
        dataBaseRepository?.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseDidInsertedContentOn(let table, let id):
                    // New record added
                    ()
                case .databaseDidUpdatedContentOn: break
                case .databaseDidDeletedContentOn(let table, let id):
                    // Record deleted! Route back
                    ()
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn(let table):
                    // Data changed. Reload!
                    ()
                }
            }
        }.store(in: cancelBag)
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
