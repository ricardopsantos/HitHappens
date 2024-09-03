//
//  EventLogDetailsViewModel.swift
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
import DesignSystem

//
// MARK: - Model
//

public struct EventLogDetailsModel: Equatable, Hashable, Sendable {
    let trackedLog: Model.TrackedLog
    init(trackedLog: Model.TrackedLog) {
        self.trackedLog = trackedLog
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension EventLogDetailsViewModel {
    enum ConfirmationSheet {
        case delete

        var title: String {
            switch self {
            case .delete:
                "Alert".localizedMissing
            }
        }

        var subTitle: String {
            switch self {
            case .delete:
                "Are you sure you want to delete?".localizedMissing
            }
        }
    }
}

extension EventLogDetailsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case reload
        case userDidChangedNote(value: String)
        case delete(confirmed: Bool)
        case handleConfirmation
    }

    struct Dependencies {
        let model: EventLogDetailsModel
        let onPerformRouteBack: () -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class EventLogDetailsViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var trackedLog: Model.TrackedLog?
    @Published var confirmationSheetType: ConfirmationSheet?
    @Published var userMessage: (text: String, color: ColorSemantic) = ("", .clear)
    @Published var note: String = ""
    @Published var eventDate: Date = .now
    @Published var mapItems: [GenericMapView.ModelItem] = []
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    private let onPerformRouteBack: () -> Void
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.trackedLog = dependencies.model.trackedLog
        self.onPerformRouteBack = dependencies.onPerformRouteBack
        super.init()
        startListeningDBChanges()
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear:
            guard let unwrapped = trackedLog else {
                return
            }
            updateUI(event: unwrapped)
        case .didDisappear: ()
        case .reload:
            guard let unwrapped = trackedLog else {
                return
            }
            Task { [weak self] in
                guard let self = self else { return }
                if let record = dataBaseRepository?.trackedLogGet(
                    trackedLogId: unwrapped.id,

                    cascade: true) {
                    updateUI(event: record)
                }
            }

        case .handleConfirmation:
            switch confirmationSheetType {
            case .delete:
                send(.delete(confirmed: true))
            case nil:
                let errorMessage = "No bottom sheet found"
                alertModel = .init(type: .error, message: errorMessage)
                ErrorsManager.handleError(message: "\(Self.self).\(action)", error: nil)
            }

        case .userDidChangedNote(value: let value):
            userMessage = ("", .clear)
            Task { [weak self] in
                guard let self = self, var trackedLog = trackedLog else { return }
                trackedLog.note = value
                dataBaseRepository?.trackedLogInsertOrUpdate(
                    trackedLog: trackedLog,
                    trackedEntityId: trackedLog.cascadeEntity?.id ?? "")
            }

        case .delete(confirmed: let confirmed):
            if !confirmed {
                confirmationSheetType = .delete
            } else {
                Task { [weak self] in
                    guard let self = self, let trackedLog = trackedLog else { return }
                    dataBaseRepository?.trackedLogDelete(trackedLogId: trackedLog.id)
                }
            }
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventLogDetailsViewModel {
    func updateUI(event model: Model.TrackedLog) {
        trackedLog = model
        note = model.note
        eventDate = model.recordDate
        if model.latitude != 0, model.longitude != 0, let cascadeEntity = model.cascadeEntity {
            let category = cascadeEntity.category
            mapItems = [GenericMapView.ModelItem.with(
                id: model.id,
                name: cascadeEntity.name,
                coordinate: .init(
                    latitude: model.latitude,
                    longitude: model.longitude),
                onTap: {},
                category: category)]
        }
    }

    func startListeningDBChanges() {
        dataBaseRepository?.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseDidInsertedContentOn: break
                case .databaseDidUpdatedContentOn(let table, let id):
                    // Data changed. Reload!
                    if table == "\(CDataTrackedLog.self)", id == self?.trackedLog?.id {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)\(#function)") { [weak self] in
                            self?.send(.reload)
                            self?.userMessage = ("Updated\n\(Date().timeStyleMedium)".localizedMissing, ColorSemantic.allCool)
                        }
                    }
                case .databaseDidDeletedContentOn(let table, let id):
                    // Record deleted! Route back
                    if table == "\(CDataTrackedLog.self)", id == self?.trackedLog?.id {
                        self?.onPerformRouteBack()
                    }
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn: break
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
    EventLogDetailsViewCoordinator(
        model: .init(trackedLog: .random), haveNavigationStack: false)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif