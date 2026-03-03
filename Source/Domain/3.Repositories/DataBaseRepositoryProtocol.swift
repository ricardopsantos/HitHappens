//
//  DataBaseRepositoryProtocol.swift
//  Domain
//
//  Created by Ricardo Santos on 22/08/2024.
//

import Foundation
import Combine
//
import Common

// MARK: - Sub-protocols

/// Reactive database change notifications (subscribe / publish).
public protocol DatabaseOutputRepositoryProtocol {
    typealias OutputType = CommonBaseCoreDataManagerOutput
    func emit(event: OutputType)
    func output(_ filter: [OutputType]) -> AnyPublisher<OutputType, Never>
    static func emit(event: OutputType)
    static func output(_ filter: [OutputType]) -> AnyPublisher<OutputType, Never>
}

/// Read-only queries for `TrackedEntity` records.
public protocol TrackedEntityReadRepositoryProtocol {
    @discardableResult func trackedEntityGet(trackedEntityId: String, cascade: Bool) -> Model.TrackedEntity?
    @discardableResult func trackedEntityGetAll(favorite: Bool?, archived: Bool?, cascade: Bool) -> [Model.TrackedEntity]
}

/// Mutating operations for `TrackedEntity` records.
public protocol TrackedEntityWriteRepositoryProtocol {
    @discardableResult func trackedEntityInsertOrUpdate(trackedEntity: Model.TrackedEntity) -> String
    @discardableResult func trackedEntityInsert(trackedEntity: Model.TrackedEntity) -> String
    @discardableResult func trackedEntityUpdate(trackedEntity: Model.TrackedEntity) -> String
    func trackedEntityDelete(trackedEntityId: String)
    func trackedEntityDelete(trackedEntity: Model.TrackedEntity)
    func trackedEntityDeleteAll()
}

/// Full CRUD for `TrackedLog` records.
public protocol TrackedLogRepositoryProtocol {
    func trackedLogGetAll(min: Date, maxDate: Date, cascade: Bool) -> [Model.TrackedLog]
    func trackedLogGetAll(
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?,
        cascade: Bool
    ) -> [Model.TrackedLog]
    func trackedLogInsertOrUpdate(trackedLog: Model.TrackedLog, trackedEntityId: String)
    func trackedLogGetAll(cascade: Bool) -> [Model.TrackedLog]
    func trackedLogGet(trackedEntityId: String?, cascade: Bool) -> [Model.TrackedLog]
    func trackedLogGet(trackedLogId: String?, cascade: Bool) -> Model.TrackedLog?
    func trackedLogDelete(trackedLogId: String)
    func trackedLogDelete(trackedEntityId: String)
}

// MARK: - Composite Protocol

/// Full database repository — combines all four focused sub-protocols.
/// Retained for backward-compatibility and for consumers that genuinely
/// need the complete surface (e.g. `EventDetailsViewModel`).
/// Prefer the narrower sub-protocols for ViewModels that only need a subset.
public protocol DataBaseRepositoryProtocol:
    DatabaseOutputRepositoryProtocol,
    TrackedEntityReadRepositoryProtocol,
    TrackedEntityWriteRepositoryProtocol,
    TrackedLogRepositoryProtocol {}
