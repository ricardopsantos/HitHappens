//
//  FavoriteEventsViewModel.swift
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

public struct FavoriteEventsModel: Equatable, Hashable, Sendable {
    let favorits: [Model.TrackedEntity]
    init(favorits: [Model.TrackedEntity] = []) {
        self.favorits = favorits
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension FavoriteEventsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case addNewEvent(trackedEntityId: String)
        case loadFavorits
    }

    struct Dependencies {
        let model: FavoriteEventsModel
        let onShouldDisplayTrackedLog: (Model.TrackedLog) -> Void
        let onShouldDisplayTrackedEntity: (Model.TrackedEntity) -> Void
        let onShouldDisplayNewTrackedEntity: () -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class FavoriteEventsViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var favorits: [Model.TrackedEntity] = []
    /// Exposed so the View can react without embedding business logic in `onChange`.
    var isLocationTrackingNeeded: Bool {
        favorits.contains(where: \.locationRelevant)
    }
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    private let onShouldDisplayTrackedLog: (Model.TrackedLog) -> Void
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.favorits = dependencies.model.favorits
        self.onShouldDisplayTrackedLog = dependencies.onShouldDisplayTrackedLog
        super.init()
        startListeningEvents()
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear:
            send(.loadFavorits)
        case .didDisappear: ()
        case .loadFavorits:
            Task { [weak self] in
                guard let self = self else { return }
                if let records = dataBaseRepository?.trackedEntityGetAll(
                    favorite: true,
                    archived: false,
                    cascade: true) {
                    favorits = records
                }
            }
        case .addNewEvent(trackedEntityId: let trackedEntityId):
            Task { [weak self] in
                guard let self = self else { return }
                var resolvedId = trackedEntityId
                if resolvedId.isEmpty {
                    resolvedId = favorits.first?.id.description ?? ""
                }
                let locationRelevant = favorits.first(where: { $0.id == resolvedId })?.locationRelevant ?? false
                insertTrackedLog(
                    trackedEntityId: resolvedId,
                    locationRelevant: locationRelevant,
                    using: dataBaseRepository
                )
            }
        }
    }
}

//
// MARK: - Listen
//

fileprivate extension FavoriteEventsViewModel {
    func startListeningEvents() {
        dataBaseRepository?.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseReloaded: ()
                case .databaseDidInsertedContentOn(let table, let id):
                    // New record added
                    // if table == "\(CDataTrackedEntity.self)" {
                    //    Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
                    //        self?.send(.loadFavorits)
                    //      }
                    //    } else
                    if table == "\(CDataTrackedLog.self)" {
                        if let trackedEntity = self?.dataBaseRepository?.trackedLogGet(trackedLogId: id, cascade: true) {
                            Common_Utils.delay(Common.Constants.defaultAnimationsTime) { [weak self] in
                                // Small delay so that the UI counter animation is viewed
                                self?.alertModel = .init(
                                    type: .success,
                                    location: .bottom,
                                    message: "\(AppConstants.entityOccurrenceSingle) tracked!\n\n(Tap here to edit/add details.)",
                                    onUserTapGesture: { [weak self] in
                                        self?.onShouldDisplayTrackedLog(trackedEntity)
                                    })
                            }
                        }
                    }
                case .databaseDidUpdatedContentOn:
                    ()
                // Entity updated
                /* if table == "\(CDataTrackedEntity.self)" {
                     Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
                         self?.send(.loadFavorits)
                     }
                 }*/
                case .databaseDidDeletedContentOn(let table, _):
                    if table == "\(CDataTrackedLog.self)" || table == "\(CDataTrackedEntity.self)" {
                        // Record deleted
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
                            self?.send(.loadFavorits)
                        }
                    }
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn(let table):
                    if table == "\(CDataTrackedLog.self)" || table == "\(CDataTrackedEntity.self)" {
                        // Record updated
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
                            self?.send(.loadFavorits)
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
    FavoriteEventsViewCoordinator(presentationStyle: .fullScreenCover)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
