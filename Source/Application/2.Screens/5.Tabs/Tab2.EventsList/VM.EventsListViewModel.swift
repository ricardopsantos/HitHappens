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
    typealias RepositoryProtocols = DatabaseOutputRepositoryProtocol &
        TrackedEntityReadRepositoryProtocol &
        TrackedEntityWriteRepositoryProtocol

    enum Actions {
        case didAppear
        case didDisappear
        case loadEvents
        case toggleFavorite(trackedEntityId: String)
        case toggleArchived(trackedEntityId: String)
    }

    struct Dependencies {
        let model: EventsListModel
        let onShouldDisplayTrackedEntity: (Model.TrackedEntity) -> Void
        let onShouldDisplayNewTrackedEntity: () -> Void
        let dataBaseRepository: RepositoryProtocols
    }
}

//
// MARK: - ViewModel
//
@Observable
class EventsListViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    private(set) var message: String = ""
    private(set) var events: [Model.TrackedEntity] = []
    private let cancelBag = CancelBag()
    private let dataBaseRepository: RepositoryProtocols?
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.message = dependencies.model.message
        super.init()
        startListeningEvents()
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear:
            send(.loadEvents)
        case .didDisappear: ()
        case .loadEvents:
            Task { [weak self] in
                guard let self = self else { return }
                if let records = await dataBaseRepository?.trackedEntityGetAll(
                    favorite: nil,
                    archived: nil,
                    cascade: true) {
                    let sorted = records.sorted(by: { $0.favorite && !$1.favorite })
                    if sorted != events {
                        events = sorted
                    }
                }
            }
        case .toggleFavorite(trackedEntityId: let trackedEntityId):
            // Fetch without cascade so the update leaves the logs untouched
            guard var trackedEntity = dataBaseRepository?.trackedEntityGet(
                trackedEntityId: trackedEntityId, cascade: false) else { return }
            trackedEntity.favorite.toggle()
            dataBaseRepository?.trackedEntityUpdate(trackedEntity: trackedEntity)
        case .toggleArchived(trackedEntityId: let trackedEntityId):
            guard var trackedEntity = dataBaseRepository?.trackedEntityGet(
                trackedEntityId: trackedEntityId, cascade: false) else { return }
            trackedEntity.archived.toggle()
            if trackedEntity.archived {
                // Archived trackers shouldn't linger on the quick-log tab
                trackedEntity.favorite = false
            }
            dataBaseRepository?.trackedEntityUpdate(trackedEntity: trackedEntity)
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventsListViewModel {
    func startListeningEvents() {
        let instanceID = instanceID
        dataBaseRepository?.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseReloaded: ()
                case .databaseDidInsertedContentOn: break
                case .databaseDidUpdatedContentOn: break
                case .databaseDidDeletedContentOn(_, let table):
                    if table == "\(CDataTrackedLog.self)" || table == "\(CDataTrackedEntity.self)" {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)|\(instanceID)") { [weak self] in
                            self?.send(.loadEvents)
                        }
                    }
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn(let table):
                    if table == "\(CDataTrackedLog.self)" || table == "\(CDataTrackedEntity.self)" {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)|\(instanceID)") { [weak self] in
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
        .environment(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(RouterViewModel())
}
#endif
