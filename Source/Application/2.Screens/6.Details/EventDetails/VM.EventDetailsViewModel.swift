//
//  EventDetailsViewModel.swift
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
import DevTools

//
// MARK: - Model
//

public struct CascadeEventListItem: Equatable, Hashable, Sendable {
    let id: String
    let title: String
    let value: String
    init(id: String, title: String, value: String) {
        self.title = title
        self.value = value
        self.id = id
    }
}

public struct EventDetailsModel: Equatable, Hashable, Sendable {
    let event: Model.TrackedEntity
    init(event: Model.TrackedEntity) {
        self.event = event
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension EventDetailsViewModel {
    enum ConfirmationSheet {
        case delete
        case save
        case resetOccurrences
        var title: String {
            "Alert".localizedMissing
        }

        var subTitle: String {
            switch self {
            case .delete:
                "Are you sure you want to delete this \(AppConstants.entityNameSingle.lowercased())? All the \(AppConstants.entityOccurrenceNamePlural1.lowercased()) associated to it will be deleted!"
                    .localizedMissing
            case .save:
                "Are you sure you want to save  \(AppConstants.entityNameSingle.lowercased())?".localizedMissing
            case .resetOccurrences:
                "Are you sure you want to resent the counter?".localizedMissing
            }
        }
    }
}

extension EventDetailsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case reload
        case userDidChangedArchived(value: Bool)
        case usedDidTappedLogEvent(trackedLogId: String)
        case handleConfirmation
        case addNewLog
        case resetAllOccurrences(confirmed: Bool)
        case deleteEvent(confirmed: Bool)
        case saveEvent(confirmed: Bool)
    }

    struct Dependencies {
        let model: EventDetailsModel?
        let onPerformRouteBack: () -> Void
        let onShouldDisplayTrackedLog: (Model.TrackedLog) -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
        let presentationStyle: ViewPresentationStyle
    }
}

//
// MARK: - ViewModel
//
class EventDetailsViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published var trackedEntity: Model.TrackedEntity?
    @Published var isNewEvent: Bool = false
    @Published var trackedEntityUpdated: Date?
    @Published private(set) var logs: [CascadeEventListItem]?
    @Published var id: String = ""
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    private let onPerformRouteBack: () -> Void
    private let onShouldDisplayTrackedLog: (Model.TrackedLog) -> Void
    @Published var confirmationSheetType: ConfirmationSheet?

    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.trackedEntity = dependencies.model?.event
        self.onPerformRouteBack = dependencies.onPerformRouteBack
        self.onShouldDisplayTrackedLog = dependencies.onShouldDisplayTrackedLog
        super.init()
        startListeningDBChanges()
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear:
            guard let unwrapped = trackedEntity else {
                isNewEvent = true
                trackedEntity = .new
                return
            }
            isNewEvent = false
            updateUI(event: unwrapped)
        case .didDisappear: ()
        case .reload:
            guard let unwrapped = trackedEntity else {
                return
            }
            Task { [weak self] in
                guard let self = self else { return }
                if let record = dataBaseRepository?.trackedEntityGet(
                    trackedEntityId: unwrapped.id, cascade: true) {
                    updateUI(event: record)
                }
            }

        case .userDidChangedArchived(value: let value):
            displayTip("")
            if isNewEvent {
                trackedEntity?.archived = value
            } else {
                Task { [weak self] in
                    guard let self = self, var trackedEntity = trackedEntity,
                          value != trackedEntity.archived else { return }
                    trackedEntity.archived = value
                    if value {
                        // archived cant be favorite
                        trackedEntity.favorite = false
                    }
                    trackedEntity.cascadeEvents = nil // So it does not update cascade events
                    dataBaseRepository?.trackedEntityUpdate(
                        trackedEntity: trackedEntity)
                    if value {
                        displayTip("On the \(AppConstants.entityNamePlural) list, this event will now appear on the last section".localizedMissing)
                    }
                }
            }

        case .usedDidTappedLogEvent(trackedLogId: let trackedLogId):
            displayTip("")
            Task { [weak self] in
                guard let self = self else { return }
                if let trackedLog = dataBaseRepository?.trackedLogGet(trackedLogId: trackedLogId, cascade: true) {
                    onShouldDisplayTrackedLog(trackedLog)
                }
            }

        case .addNewLog:
            displayTip("")
            Task { [weak self] in
                guard let self = self else { return }
                let trackedEntityId = trackedEntity?.id ?? ""
                guard !trackedEntityId.isEmpty else {
                    DevTools.Log.error("Invalid trackedEntityId", .business)
                    return
                }
                let locationRelevant = trackedEntity?.locationRelevant ?? false
                let location = Common.SharedLocationManager.lastKnowLocation?.coordinate
                if locationRelevant, let location = location {
                    Common.LocationUtils.getAddressFrom(
                        latitude: location.latitude,
                        longitude: location.longitude) { [weak self] result in
                            let event: Model.TrackedLog = .init(
                                latitude: location.latitude,
                                longitude: location.longitude,
                                addressMin: result.addressMin,
                                note: "")
                            self?.dataBaseRepository?.trackedLogInsertOrUpdate(trackedLog: event, trackedEntityId: trackedEntityId)
                        }
                } else {
                    let event: Model.TrackedLog = .init(latitude: 0, longitude: 0, addressMin: "", note: "")
                    dataBaseRepository?.trackedLogInsertOrUpdate(trackedLog: event, trackedEntityId: trackedEntityId)
                }
            }
        case .handleConfirmation:
            displayTip("")
            switch confirmationSheetType {
            case .delete:
                send(.deleteEvent(confirmed: true))
            case .save:
                send(.saveEvent(confirmed: true))
            case .resetOccurrences:
                send(.resetAllOccurrences(confirmed: true))
            case nil:
                let errorMessage = "No bottom sheet found"
                alertModel = .init(type: .error, message: errorMessage)
                ErrorsManager.handleError(message: "\(Self.self).\(action)", error: nil)
                
            }

        case .deleteEvent(confirmed: let confirmed):
            displayTip("")
            if !confirmed {
                confirmationSheetType = .delete
            } else {
                Task { [weak self] in
                    guard let self = self, let trackedEntity = trackedEntity else { return }
                    dataBaseRepository?.trackedEntityDelete(trackedEntity: trackedEntity)
                }
            }
        case .saveEvent(confirmed: let confirmed):
            if !confirmed {
                confirmationSheetType = .save
            } else {
                Task { [weak self] in
                    guard let self = self, var trackedEntity = trackedEntity else { return }
                    trackedEntity.cascadeEvents = nil // So it does not update cascade events
                    if let trackedEntityId = dataBaseRepository?.trackedEntityInsertOrUpdate(trackedEntity: trackedEntity) {
                        self.isNewEvent = false
                        self.confirmationSheetType = nil
                        self.trackedEntity = dataBaseRepository?.trackedEntityGet(trackedEntityId: trackedEntityId, cascade: true)
                    }
                }
            }
        case .resetAllOccurrences(confirmed: let confirmed):
            if !confirmed {
                confirmationSheetType = .resetOccurrences
            } else {
                Task { [weak self] in
                    guard let self = self, var trackedEntity = trackedEntity else { return }
                    trackedEntity.cascadeEvents = [] // This will delete all events on the save
                    if let trackedEntityId = dataBaseRepository?.trackedEntityInsertOrUpdate(trackedEntity: trackedEntity) {
                        self.isNewEvent = false
                        self.confirmationSheetType = nil
                        self.trackedEntity = dataBaseRepository?.trackedEntityGet(trackedEntityId: trackedEntityId, cascade: true)
                    }
                }
            }        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventDetailsViewModel {
    func updateUI(event model: Model.TrackedEntity) {
        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
            self?.trackedEntityUpdated = Date()
            let count = model.cascadeEvents?.count ?? 0
            self?.logs = model.cascadeEvents?
                .sorted(by: { $0.recordDate > $1.recordDate })
                .enumerated()
                .map { index, event in
                    .init(
                        id: event.id,
                        title: "\(count - index). \(event.localizedListItemTitleV1)",
                        value: event.localizedListItemValueV1)
                }
            self?.trackedEntity = model
        }
    }

    func startListeningDBChanges() {
        dataBaseRepository?.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseDidInsertedContentOn(let table, let id):
                    // New record added
                    if table == "\(CDataTrackedLog.self)" {
                        if let trackedEntity = self?.dataBaseRepository?.trackedLogGet(trackedLogId: id, cascade: true) {
                            Common_Utils.delay(Common.Constants.defaultAnimationsTime) { [weak self] in
                                // Small delay so that the UI counter animation is viewed
                                self?.alertModel = .init(
                                    type: .success,
                                    location: .bottom,
                                    message: "\(AppConstants.entityOccurrenceSingle) tracked!\nTap for edit/add details.",
                                    onUserTapGesture: { [weak self] in
                                        self?.onShouldDisplayTrackedLog(trackedEntity)
                                    })
                            }
                        }
                    }
                case .databaseDidUpdatedContentOn: break
                case .databaseDidDeletedContentOn(let table, let id):
                    // Record deleted! Route back
                    if table == "\(CDataTrackedEntity.self)", id == self?.trackedEntity?.id {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)\(#function).Deleted") { [weak self] in
                            self?.onPerformRouteBack()
                        }
                    }
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn(let table):
                    // Data changed. Reload!
                    if table == "\(CDataTrackedEntity.self)" {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)\(#function)") { [weak self] in
                            self?.send(.reload)
                        }
                    }
                    if table == "\(CDataTrackedLog.self)" {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)\(#function)") { [weak self] in
                            self?.send(.reload)
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
@available(iOS 17, *)
#Preview {
    EventDetailsViewCoordinator(
        model: .init(event: .random(cascadeEvents: [.random])), haveNavigationStack: false)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
