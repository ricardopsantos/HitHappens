//
//  EventsCalendarViewModel.swift
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

public struct EventsCalendarModel: Equatable, Hashable, Sendable {
    let message: String

    init(message: String = "") {
        self.message = message
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension EventsCalendarViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case loadEvents(fullMonth: Bool, value: Date?)
        case usedDidTappedLogEvent(trackedLogId: String)
    }

    struct Dependencies {
        let model: EventsCalendarModel
        let onShouldDisplayTrackedLog: (Model.TrackedLog) -> Void
        let dataBaseRepository: DatabaseOutputRepositoryProtocol & TrackedLogRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
@Observable
class EventsCalendarViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    private(set) var message: String = ""
    private(set) var events: [Model.TrackedEntity] = []
    private(set) var logs: [CascadeEventListItem]?
    var selectedDay: Date?
    var selectedMonth: Date = .now
    var eventsForDay: [Date: [Color]] = [:]
    /// Distinct categories with activity on the visible month — feeds the color legend.
    var categoriesInMonth: [HitHappensEventCategory] = []
    private let cancelBag = CancelBag()
    private let dataBaseRepository: (DatabaseOutputRepositoryProtocol & TrackedLogRepositoryProtocol)?
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
        case .didAppear:
            send(.loadEvents(fullMonth: true, value: Date()))
        case .didDisappear: ()
        case .loadEvents(fullMonth: let fullMonth, let value):
            Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)|\(instanceID)") { [weak self] in
                Task { [weak self] in
                    guard let self = self else { return }
                    let min: Date!
                    let max: Date!
                    if let value = value, !fullMonth {
                        min = value.beginningOfDay ?? Date().beginningOfDay
                        max = value.endOfDay ?? Date().endOfDay
                    } else {
                        min = value?.beginningOfMonth ?? selectedMonth.beginningOfMonth
                        max = value?.endOfMonth ?? selectedMonth.endOfMonth
                    }
                    if let records = self.dataBaseRepository?.trackedLogGetAll(min: min, maxDate: max, cascade: true) {
                        updateUI(logs: records, canUpdateEventsForDay: fullMonth)
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

fileprivate extension EventsCalendarViewModel {
    func updateUI(logs trackedLogs: [Model.TrackedLog], canUpdateEventsForDay: Bool) {
        // Equality guards throughout: @Observable fires on set, not on change,
        // and this runs on every debounced DB event.
        let count = trackedLogs.count
        let newLogs: [CascadeEventListItem] = trackedLogs
            .sorted(by: { $0.recordDate > $1.recordDate })
            .enumerated()
            .map { index, event in
                .init(
                    id: event.id,
                    title: "\(count - index). \(event.localizedListItemTitleV2(cascadeTrackedEntity: event.cascadeEntity))",
                    value: event.localizedListItemValueV2)
            }
        if newLogs != logs {
            logs = newLogs
        }
        if canUpdateEventsForDay {
            var eventsForDayAcc: [Date: [Color]] = [:]
            trackedLogs.forEach { log in
                let key = log.recordDate.middleOfDay
                let color = log.cascadeEntity?.category.color
                if let key = key, let color = color {
                    eventsForDayAcc[key, default: []].append(color)
                }
            }
            if eventsForDayAcc != eventsForDay {
                eventsForDay = eventsForDayAcc
            }
            let newCategories = Array(Set(trackedLogs.compactMap(\.cascadeEntity?.category)))
                .sorted(by: { $0.localized < $1.localized })
            if newCategories != categoriesInMonth {
                categoriesInMonth = newCategories
            }
        }
    }

    func startListeningEvents() {
        let instanceID = instanceID
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
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)|\(instanceID)") { [weak self] in
                            self?.send(.loadEvents(fullMonth: true, value: Date()))
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
    EventsCalendarViewCoordinator(presentationStyle: .fullScreenCover)
        .environment(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(RouterViewModel())
}
#endif
