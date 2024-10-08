//
//  EventsMapViewModel.swift
//  Common
//
//  Created by Ricardo Santos on 22/08/24.
//

import Foundation
import SwiftUI
import MapKit
//
import Domain
import Common
import Core
import DesignSystem

//
// MARK: - Model
//

public struct EventsMapModel: Equatable, Hashable, Sendable {
    let message: String

    init(message: String = "") {
        self.message = message
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension EventsMapViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case loadEvents(region: MKCoordinateRegion)
        case usedDidTappedLogEvent(trackedLogId: String)
    }

    struct Dependencies {
        let model: EventsMapModel
        let onShouldDisplayTrackedLog: (Model.TrackedLog) -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class EventsMapViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var message: String = ""
    @Published var mapItems: [GenericMapView.ModelItem] = []
    @Published private(set) var logs: [CascadeEventListItem]?
    private var lastRegion: MKCoordinateRegion?
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    private let onShouldDisplayTrackedLog: (Model.TrackedLog) -> Void
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.message = dependencies.model.message
        self.onShouldDisplayTrackedLog = dependencies.onShouldDisplayTrackedLog
        super.init()
        startListeningEvents()
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        case .loadEvents(region: let region):
            Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
                self?.lastRegion = region
                Task { [weak self] in
                    guard let self = self else { return }
                    if let records = self.dataBaseRepository?.trackedLogGetAll(
                        minLatitude: region.latitudeMin,
                        maxLatitude: region.latitudeMax,
                        minLongitude: region.longitudeMin,
                        maxLongitude: region.longitudeMax,
                        cascade: true) {
                        updateUI(logs: records)
                    }
                }
            }
        case .usedDidTappedLogEvent(trackedLogId: let trackedLogId):
            Task { [weak self] in
                guard let self = self else { return }
                if let trackedLog = dataBaseRepository?.trackedLogGet(trackedLogId: trackedLogId, cascade: true) {
                    onShouldDisplayTrackedLog(trackedLog)
                }
            }
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventsMapViewModel {
    func updateUI(logs trackedLogs: [Model.TrackedLog]) {
        let count = trackedLogs.count
        logs = trackedLogs
            .sorted(by: { $0.recordDate > $1.recordDate })
            .enumerated()
            .map { index, event in
                .init(
                    id: event.id,
                    title: "\(count - index). \(event.localizedListItemTitleV2(cascadeTrackedEntity: event.cascadeEntity))",
                    value: event.localizedListItemValueV2)
            }
        mapItems = trackedLogs.map { .with(trackedLog: $0, onTap: {}) }
    }

    func startListeningEvents() {
        dataBaseRepository?.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseReloaded: ()
                case .databaseDidInsertedContentOn: break
                case .databaseDidUpdatedContentOn: break
                case .databaseDidDeletedContentOn: break
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn(let table):
                    if table == "\(CDataTrackedLog.self)" {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
                            if let lastRegion = self?.lastRegion {
                                self?.send(.loadEvents(region: lastRegion))
                            }
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
    EventsMapViewCoordinator(presentationStyle: .fullScreenCover)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
