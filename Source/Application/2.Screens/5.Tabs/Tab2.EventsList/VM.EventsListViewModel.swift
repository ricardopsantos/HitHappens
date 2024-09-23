//
//  EventsListViewModel.swift
//  Common
//
//  Created by Ricardo Santos on 22/08/24.
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

public struct EventsListModel: Equatable, Hashable, Sendable {
    let message: String

    init(message: String = "") {
        self.message = message
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension EventsListViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case loadEvents
    }

    struct Dependencies {
        let model: EventsListModel
        let onShouldDisplayTrackedEntity: (Model.TrackedEntity) -> Void
        let onShouldDisplayNewTrackedEntity: () -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class EventsListViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var message: String = ""
    @Published private(set) var events: [Model.TrackedEntity] = []
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.message = dependencies.model.message
        super.init()
        startListeningDBChanges()
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear:
            send(.loadEvents)
        case .didDisappear: ()
        case .loadEvents:
            Task { [weak self] in
                guard let self = self else { return }
                if let records = dataBaseRepository?.trackedEntityGetAll(
                    favorite: nil,
                    archived: nil,
                    cascade: true) {
                    events = records
                        .sorted(by: { $0.favorite != $1.favorite })
                }
            }
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventsListViewModel {
    func startListeningDBChanges() {
        dataBaseRepository?.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseDidInsertedContentOn: break
                case .databaseDidUpdatedContentOn: break
                case .databaseDidDeletedContentOn(_, let table):
                    if table == "\(CDataTrackedLog.self)" || table == "\(CDataTrackedEntity.self)" {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
                            self?.send(.loadEvents)
                        }
                    }
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn(let table):
                    if table == "\(CDataTrackedLog.self)" || table == "\(CDataTrackedEntity.self)" {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
                            self?.send(.loadEvents)
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
    EventsListViewCoordinator(presentationStyle: .fullScreenCover)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
