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
                "Are you sure you want to delete \(AppConstants.entityOccurrenceSingle.lowercased())?".localizedMissing
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
        case userDidChangedDate(value: Date)
        case userDidChangedLocation(address: String, latitude: Double, longitude: Double)
        case delete(confirmed: Bool)
        case handleConfirmation
    }

    struct Dependencies {
        let model: EventLogDetailsModel
        let onPerformDisplayEntityDetails: ((Model.TrackedEntity) -> Void)?
        let onPerformRouteBack: () -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
        let presentationStyle: ViewPresentationStyle
    }
}

//
// MARK: - ViewModel
//
class EventLogDetailsViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var trackedLog: Model.TrackedLog?
    @Published var confirmationSheetType: ConfirmationSheet?
    @Published var note: String = ""
    @Published var eventDate: Date = .now
    @Published var address: String = ""
    @Published var addressLatitude: Double = 0
    @Published var addressLongitude: Double = 0
    @Published var mapItems: [GenericMapView.ModelItem] = []
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    private let onPerformRouteBack: () -> Void
    private let screenID = UUID().uuidString
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.trackedLog = dependencies.model.trackedLog
        self.onPerformRouteBack = dependencies.onPerformRouteBack
        super.init()
        startListeningEvents()
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
            tip = ("", .clear)
            Task { [weak self] in
                guard let self = self, var trackedLog = trackedLog, trackedLog.note != value else { return }
                trackedLog.note = value
                dataBaseRepository?.trackedLogInsertOrUpdate(
                    trackedLog: trackedLog,
                    trackedEntityId: trackedLog.cascadeEntity?.id ?? "")
            }
        case .userDidChangedLocation(address: let address, latitude: let latitude, longitude: let longitude):
            tip = ("", .clear)
            Task { [weak self] in
                guard let self = self,
                      var trackedLog = trackedLog,
                      !address.trim.isEmpty,
                      trackedLog.addressMin != address,
                      latitude != 0, longitude != 0 else { return }
                trackedLog.addressMin = address
                trackedLog.latitude = latitude
                trackedLog.longitude = longitude
                dataBaseRepository?.trackedLogInsertOrUpdate(
                    trackedLog: trackedLog,
                    trackedEntityId: trackedLog.cascadeEntity?.id ?? "")
            }
        case .userDidChangedDate(value: let value):
            tip = ("", .clear)
            Task { [weak self] in
                guard let self = self, var trackedLog = trackedLog, trackedLog.recordDate != value else { return }
                trackedLog.recordDate = value
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
        address = model.addressMin
        addressLatitude = model.latitude
        addressLongitude = model.longitude
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

    func startListeningEvents() {
        dataBaseRepository?.output([]).sink { [weak self] some in
            guard let screenID = self?.screenID else { return }
            switch some {
            case .generic(let some):
                switch some {
                case .databaseReloaded: ()
                case .databaseDidInsertedContentOn: break
                case .databaseDidUpdatedContentOn(let table, let id):
                    // Data changed. Reload!
                    if table == "\(CDataTrackedLog.self)", id == self?.trackedLog?.id {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)\(#function).\(screenID)") { [weak self] in
                            self?.send(.reload)
                        }
                    }
                case .databaseDidDeletedContentOn(let table, _):
                    if table == "\(CDataTrackedLog.self)" {
                        // Record deleted! Route back
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)\(#function).\(screenID)") { [weak self] in
                            self?.onPerformRouteBack()
                        }
                    } else if table == "\(CDataTrackedEntity.self)" {
                        // Entity deleted! Route back
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)\(#function).\(screenID)") { [weak self] in
                            self?.onPerformRouteBack()
                        }
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

#Preview {
    EventLogDetailsViewCoordinator(
        presentationStyle: .fullScreenCover, model: .init(trackedLog: .random))
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
