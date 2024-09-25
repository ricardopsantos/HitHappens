//
//  CloudKitService.swift
//  Core
//
//  Created by Ricardo Santos on 23/09/2024.
//

import Foundation
import CloudKit
//
import Common
import Domain
import DevTools

// https://medium.com/@islammoussa.eg/implementing-seamless-app-version-management-in-ios-with-cloudkit-bf5715b78283

/**
 In CloudKit, a __zone__ is a way to organize and manage your app's data within a database. CloudKit provides two types of databases: the public and private databases, and within these, you can create custom zones.

 __1. Default Zone:__
 Each database (public or private) comes with a default zone, where records can be stored if you don’t need complex data organization.
 You can just use this zone for simpler use cases.

 __2. Custom Zones:__
 If you need more control over your data (like organizing data into groups or supporting offline syncing), you can create custom zones.
 This allows you to partition your data within the database.

 Custom zones give you more flexibility for managing data, such as:
 - Batch operations: Perform operations like saving, fetching, or deleting multiple records in one zone as a transaction.
 - Offline Support: CloudKit automatically supports offline data sync for custom zones, helping manage conflicts and merging changes when the device goes back online.
 - Atomic Transactions: You can save multiple records at once, and either all records are saved or none, ensuring data consistency.
 */
public class CloudKitService {
    private let container: CKContainer
    private let publicCloudDatabase: CKDatabase
    private let privateCloudDatabase: CKDatabase
    private var eventTrackingZone: CKRecordZone.ID?
    private var userDatabaseZone: CKRecordZone.ID?

    public init(cloudKit: String) {
        self.container = CKContainer(identifier: cloudKit)
        self.publicCloudDatabase = container.publicCloudDatabase
        self.privateCloudDatabase = container.privateCloudDatabase
        self.eventTrackingZone = CKRecordZone.ID(zoneName: "eventTrackingZone", ownerName: CKCurrentUserDefaultName)
        self.userDatabaseZone = CKRecordZone.ID(zoneName: "userDatabaseZone", ownerName: CKCurrentUserDefaultName)
    }
}

//
// MARK: - CloudKitServiceProtocol
//

extension CloudKitService: CloudKitServiceProtocol {
    public func sceneDidEnterBackground() {
        iCloudIsAvailable { [weak self] available in
            guard available else {
                return
            }
            self?.createZones { [weak self] _ in
                self?.appendEvent(event: CKRecord.appLifeCicleEvent(name: "AppDidEnterBackground")) { _ in }
                self?.performDBBackup(completion: { _ in })
            }
        }
    }
    
    public func appDidFinishLaunchingWithOptions() {
        iCloudIsAvailable { [weak self] available in
            guard available else {
                return
            }
            self?.createZones { [weak self] _ in
                self?.appendEvent(event: CKRecord.appLifeCicleEvent(name: "AppDidFinishLaunchingWithOptions")) { _ in }
                self?.performDBBackup(completion: { _ in })
            }
        }
    }

    public func appStarted() {
        iCloudIsAvailable { [weak self] available in
            guard available else {
                return
            }
            self?.createZones { [weak self] _ in
                self?.appendEvent(event: CKRecord.appLifeCicleEvent(name: "AppStarted")) { _ in }
                self?.performDBBackup(completion: { _ in })
            }
        }
    }
    
    public func fetchAppVersion() async -> Model.AppVersion? {
        try? await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else { return }
            fetchAppVersion { some in
                switch some {
                case .success(let some):
                    continuation.resume(returning: some)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

//
// MARK: - Private
//

private extension CloudKitService {
    func iCloudIsAvailable(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { accountStatus, error in
            switch accountStatus {
            case .available:
                DevTools.Log.debug("iCloud account available.", .business)
                completion(true)
            case .noAccount:
                DevTools.Log.debug("No iCloud account is signed in.", .business)
                completion(false)
            case .restricted:
                DevTools.Log.debug("iCloud access is restricted.", .business)
            case .couldNotDetermine:
                if let error = error {
                    DevTools.Log.error("Error determining iCloud status: \(error.localizedDescription)", .business)
                }
                completion(false)
            case .temporarilyUnavailable:
                DevTools.Log.debug("iCloud access is temporarily unavailable.", .business)
                completion(false)
            @unknown default:
                DevTools.Log.debug("Unknown iCloud account status.", .business)
                completion(false)
            }
        }
    }

    func createZones(completion: @escaping (Bool) -> Void) {
        iCloudIsAvailable { [weak self] available in
            guard available else { completion(false); return }
            guard let self = self else { completion(false); return }
            guard let userDatabaseZone = userDatabaseZone else { completion(false); return }
            guard let eventTrackingZone = eventTrackingZone else { completion(false); return }
            createZone(zoneID: userDatabaseZone) { [weak self] success in
                guard success else { completion(false); return }
                self?.createZone(zoneID: eventTrackingZone) { success in
                    completion(success)
                }
            }
        }
    }

    func createZone(zoneID: CKRecordZone.ID?, completion: @escaping (Bool) -> Void) {
        iCloudIsAvailable { [weak self] available in
            guard available else { return }
            guard let self = self else { return }
            guard let zoneID = zoneID else { return }
            let recordZone = CKRecordZone(zoneID: zoneID)
            let operation = CKModifyRecordZonesOperation(recordZonesToSave: [recordZone], recordZoneIDsToDelete: [])
            operation.modifyRecordZonesResultBlock = { result in
                switch result {
                case .success(let record):
                    DevTools.Log.debug("Zone created: \(record)", .business)
                    completion(true)
                case .failure(let error):
                    DevTools.Log.error("Error creating zone: \(error)", .business)
                    completion(false)
                }
            }
            operation.qualityOfService = .utility
            privateCloudDatabase.add(operation)
        }
    }

    func fetchAppVersion(completion: @escaping (Result<Model.AppVersion, Error>) -> Void) {
        iCloudIsAvailable { [weak self] available in
            guard available else {
                completion(.failure(AppErrors.genericError(devMessage: "iCloud not available")))
                return
            }
            guard let self = self else { return }
            let query = CKQuery(recordType: "AppVersion", predicate: NSPredicate(value: true))
            let operation = CKQueryOperation(query: query)
            operation.resultsLimit = 1
            var recordFound = false
            operation.recordMatchedBlock = { _, result in
                switch result {
                case .success(let record):
                    guard let storeVersion = record["store_version"] as? String,
                          let minimumVersion = record["minimum_version"] as? String else {
                        completion(.failure(AppErrors.genericError(devMessage: "Invalid record format")))
                        return
                    }
                    recordFound = true
                    completion(.success(Model.AppVersion(storeVersion: storeVersion, minimumVersion: minimumVersion)))
                case .failure(let error):
                    DevTools.Log.error(error, .business)
                    completion(.failure(error))
                }
            }
            operation.queryResultBlock = { operationResult in
                switch operationResult {
                case .success:
                    if !recordFound {
                        // No record found!
                        completion(.failure(AppErrors.genericError(devMessage: "Config not found")))
                    }
                case .failure(let error):
                    DevTools.Log.error(error, .business)
                    completion(.failure(error))
                }
            }
            publicCloudDatabase.add(operation)
        }
    }

    func performDBBackup(completion: @escaping (Bool) -> Void) {
        let query = CKQuery(recordType: "DBBackup", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1
        var recordFound = false
        operation.recordMatchedBlock = { [weak self] _, result in
            switch result {
            case .success(let record):
                // Record found. Update!
                recordFound = true
                self?.insertOrUpdateDBBackup(record, completion: completion)
            case .failure(let error):
                DevTools.Log.error(error, .business)
                completion(false)
            }
        }
        operation.queryResultBlock = { [weak self] operationResult in
            switch operationResult {
            case .success(let some):
                if !recordFound {
                    // No record found! Create first
                    self?.insertOrUpdateDBBackup(nil, completion: completion)
                }
            case .failure(let error):
                DevTools.Log.error(error, .business)
                completion(false)
            }
        }
        privateCloudDatabase.add(operation)
    }

    func insertOrUpdateDBBackup(_ record: CKRecord?, completion: @escaping (Bool) -> Void) {
        guard let zoneID = userDatabaseZone else { return }
        var record: CKRecord? = record
        if record == nil {
            // New record
            record = CKRecord(recordType: "DBBackup", zoneID: zoneID)
        }
        record?["databaseFile"] = CKAsset(fileURL: DataBaseRepository.shared.databaseURL)
        guard let record = record else { completion(false); return }
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                completion(true)
            case .failure(let error):
                DevTools.Log.error(error, .business)
                completion(false)
            }
        }
        privateCloudDatabase.add(operation)
    }

    func appendEvent(event: [String: String], completion: @escaping (Error?) -> Void) {
        iCloudIsAvailable { [weak self] available in
            guard available else { return }
            guard let self = self else { return }
            guard let zoneID = eventTrackingZone else { return }
            let recordType = "Event"
            let record = CKRecord(recordType: recordType, zoneID: zoneID)
            CKRecord.Keys.allCases.forEach { key in
                record[key.rawValue] = event[key.rawValue]
            }
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    DevTools.Log.debug("Record [\(recordType):\(String(describing: record["name"]))] saved", .business)
                case .failure(let error):
                    DevTools.Log.debug("Error saving [\(recordType)]: \(error)", .business)
                }
            }
            operation.qualityOfService = .background
            privateCloudDatabase.add(operation)
        }
    }
}

public extension CKRecord {
    enum Keys: String, CaseIterable {
        case name
        case type
        case userInfo = "user_info"
    }

    static func appLifeCicleEvent(name: String) -> [String: String] {
        var userInfo: [String: String] = [:]
        userInfo["numberOfLogins"] = Common.UserDefaultsManager.numberOfLogins.description
        userInfo["version"] = Common.AppInfo.version
        var event: [String: String] = [:]
        event[Keys.name.rawValue] = name
        event[Keys.type.rawValue] = "AppLifeCycle"
        event[Keys.userInfo.rawValue] = userInfo.description
        return event
    }
}
