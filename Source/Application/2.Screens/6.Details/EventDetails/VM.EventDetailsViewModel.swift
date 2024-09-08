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

        var title: String {
            switch self {
            case .delete:
                "Alert".localizedMissing
            case .save:
                "Alert".localizedMissing
            }
        }

        var subTitle: String {
            switch self {
            case .delete:
                "Are you sure you want to delete this \(AppConstants.entityNameSingle.lowercased())? All the \(AppConstants.entityOccurrenceNamePlural.lowercased()) associated to it will be deleted!"
                    .localizedMissing
            case .save:
                "Are you sure you want to save  \(AppConstants.entityNameSingle.lowercased())?".localizedMissing
            }
        }
    }
}

extension EventDetailsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case reload
        case userDidChangedSoundEffect(value: SoundEffect)
        case userDidChangedEventCategory(value: HitHappensEventCategory)
        case userDidChangedLocationRelevant(value: Bool)
        case userDidChangedFavorite(value: Bool)
        case userDidChangedArchived(value: Bool)
        case userDidChangedName(value: String)
        case userDidChangedInfo(value: String)
        case usedDidTappedLogEvent(trackedLogId: String)
        case handleConfirmation
        case addNewLog
        case deleteEvent(confirmed: Bool)
        case saveNewEvent(confirmed: Bool)
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
    @Published var canSaveNewEvent: Bool = false
    @Published private(set) var logs: [CascadeEventListItem]?
    @Published var soundEffect: String = SoundEffect.none.name
    @Published var category: String = HitHappensEventCategory.none.localized
    @Published var favorite: Bool = false
    @Published var archived: Bool = false
    @Published var name: String = ""
    @Published var info: String = ""
    @Published var id: String = ""
    @Published var counter: Int = 0
    @Published var locationRelevant: Bool = false
    @Published var userMessage: (text: String, color: ColorSemantic) = ("", .clear)
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
            guard !isNewEvent else { return }
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
        case .userDidChangedSoundEffect(value: let value):
            displayUserMessage("")
            value.play()
            if isNewEvent {
                trackedEntity?.sound = value

            } else {
                Task { [weak self] in
                    guard let self = self, var trackedEntity = trackedEntity else { return }
                    trackedEntity.sound = value
                    dataBaseRepository?.trackedEntityUpdate(
                        trackedEntity: trackedEntity)
                }
            }

        case .userDidChangedEventCategory(value: let value):
            displayUserMessage("")
            if isNewEvent {
                trackedEntity?.category = value

            } else {
                Task { [weak self] in
                    guard let self = self, var trackedEntity = trackedEntity else { return }
                    trackedEntity.category = value
                    dataBaseRepository?.trackedEntityUpdate(
                        trackedEntity: trackedEntity)
                }
            }

        case .userDidChangedLocationRelevant(value: let value):
            displayUserMessage("")
            if isNewEvent {
                trackedEntity?.locationRelevant = value

            } else {
                Task { [weak self] in
                    guard let self = self, var trackedEntity = trackedEntity else { return }
                    trackedEntity.locationRelevant = value
                    dataBaseRepository?.trackedEntityUpdate(
                        trackedEntity: trackedEntity)
                    if value {
                        userMessage.text = "Every time the user add a new event, the event details screen will appear"
                    }
                }
            }

        case .userDidChangedName(value: let value):
            displayUserMessage("")
            if isNewEvent {
                trackedEntity?.name = value
                canSaveNewEvent = !value.trim.isEmpty
            } else {
                Task { [weak self] in
                    guard let self = self, var trackedEntity = trackedEntity else { return }
                    trackedEntity.name = value
                    dataBaseRepository?.trackedEntityUpdate(
                        trackedEntity: trackedEntity)
                }
            }

        case .userDidChangedArchived(value: let value):
            displayUserMessage("")
            if isNewEvent {
                trackedEntity?.archived = value

            } else {
                Task { [weak self] in
                    guard let self = self, var trackedEntity = trackedEntity else { return }
                    trackedEntity.archived = value
                    if value {
                        // archived cant be favorite
                        trackedEntity.favorite = false
                    }
                    dataBaseRepository?.trackedEntityUpdate(
                        trackedEntity: trackedEntity)
                    if value {
                        displayUserMessage("On the events list, this event will now appear on the last section".localizedMissing)
                    }
                }
            }

        case .userDidChangedFavorite(value: let value):
            displayUserMessage("")
            if isNewEvent {
                trackedEntity?.favorite = value
            } else {
                Task { [weak self] in
                    guard let self = self, var trackedEntity = trackedEntity else { return }
                    trackedEntity.favorite = value
                    if value {
                        // archived cant be favorite
                        trackedEntity.archived = false
                    }
                    dataBaseRepository?.trackedEntityUpdate(
                        trackedEntity: trackedEntity)
                    if value {
                        displayUserMessage("On the events list, this event will now appear on the first section".localizedMissing)
                    }
                }
            }

        case .userDidChangedInfo(value: let value):
            displayUserMessage("")
            if isNewEvent {
                trackedEntity?.info = value
            } else {
                Task { [weak self] in
                    guard let self = self, var trackedEntity = trackedEntity else { return }
                    trackedEntity.info = value
                    dataBaseRepository?.trackedEntityUpdate(
                        trackedEntity: trackedEntity)
                }
            }

        case .usedDidTappedLogEvent(trackedLogId: let trackedLogId):
            displayUserMessage("")
            guard !isNewEvent else { return }
            Task { [weak self] in
                guard let self = self else { return }
                if let trackedLog = dataBaseRepository?.trackedLogGet(trackedLogId: trackedLogId, cascade: true) {
                    onShouldDisplayTrackedLog(trackedLog)
                }
            }

        case .addNewLog:
            displayUserMessage("")
            guard !isNewEvent else { return }
            Task { [weak self] in
                guard let self = self else { return }
                let trackedEntityId = trackedEntity?.id ?? ""
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
            displayUserMessage("")
            switch confirmationSheetType {
            case .delete:
                send(.deleteEvent(confirmed: true))
            case .save:
                send(.saveNewEvent(confirmed: true))
            case nil:
                let errorMessage = "No bottom sheet found"
                alertModel = .init(type: .error, message: errorMessage)
                ErrorsManager.handleError(message: "\(Self.self).\(action)", error: nil)
            }

        case .deleteEvent(confirmed: let confirmed):
            displayUserMessage("")
            guard !isNewEvent else { return }
            if !confirmed {
                confirmationSheetType = .delete
            } else {
                Task { [weak self] in
                    guard let self = self, let trackedEntity = trackedEntity else { return }
                    dataBaseRepository?.trackedEntityDelete(trackedEntity: trackedEntity)
                }
            }
        case .saveNewEvent(confirmed: let confirmed):
            guard isNewEvent else { return }
            if !confirmed {
                confirmationSheetType = .save
            } else {
                Task { [weak self] in
                    guard let self = self, let trackedEntity = trackedEntity else { return }
                    if let trackedEntityId = dataBaseRepository?.trackedEntityInsert(trackedEntity: trackedEntity) {
                        self.trackedEntity = dataBaseRepository?.trackedEntityGet(trackedEntityId: trackedEntityId, cascade: true)
                        self.isNewEvent = false
                        self.canSaveNewEvent = false
                    }
                }
            }
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventDetailsViewModel {
    func displayUserMessage(_ message: String) {
        userMessage.text = message
        userMessage.color = .allCool
    }

    func updateUI(event model: Model.TrackedEntity) {
        let count = model.cascadeEvents?.count ?? 0
        trackedEntity = model
        name = model.name
        info = model.info
        logs = model.cascadeEvents?
            .sorted(by: { $0.recordDate > $1.recordDate })
            .enumerated()
            .map { index, event in
                .init(
                    id: event.id,
                    title: "\(count - index). \(event.localizedListItemTitleV1)",
                    value: event.localizedListItemValueV1)
            }
        counter = model.cascadeEvents?.count ?? 0
        soundEffect = model.sound.name
        favorite = model.favorite
        archived = model.archived
        name = model.name
        info = model.info
        locationRelevant = model.locationRelevant
        category = model.category.localized
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
                                    message: "\(AppConstants.entityLogNameSingle) tracked!\nTap for edit/add details.",
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
                        self?.onPerformRouteBack()
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