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
    private var zoneID: CKRecordZone.ID?

    public init(cloudKit: String) {
        self.container = CKContainer(identifier: cloudKit)
        self.publicCloudDatabase = container.publicCloudDatabase
        self.privateCloudDatabase = container.privateCloudDatabase
        self.zoneID = CKRecordZone.ID(zoneName: "UserDefault", ownerName: CKCurrentUserDefaultName)
    }
}

//
// MARK: - CloudKitServiceProtocol
//

extension CloudKitService: CloudKitServiceProtocol {
    public func applicationDidEnterBackground() {
        iCloudIsAvailable { [weak self] available in
            guard available else {
                return
            }
            self?.createZones { [weak self] _ in
                guard let self = self else { return }
                self.addNewRecord(recordType: "Event",
                                   details: CKRecord.details(appLifeCycleEvent: "applicationDidEnterBackground"),
                                                             database: privateCloudDatabase) { _ in }
                self.performDBBackup(completion: { _ in })
            }
        }
    }

    public func appDidFinishLaunchingWithOptions() {
        iCloudIsAvailable { [weak self] available in
            guard available else {
                return
            }
            self?.createZones { [weak self] _ in
                guard let self = self else { return }
                self.addNewRecord(recordType: "Event",
                                   details: CKRecord.details(appLifeCycleEvent: "appDidFinishLaunchingWithOptions"),
                                                             database: privateCloudDatabase) { _ in }
                self.performDBBackup(completion: { _ in })
            }
        }
    }

    public func appStarted() {
        iCloudIsAvailable { [weak self] available in
            guard available else {
                return
            }
            self?.createZones { [weak self] _ in
                guard let self = self else { return }
                self.addNewRecord(recordType: "Event",
                                   details: CKRecord.details(appLifeCycleEvent: "appStarted"),
                                                             database: privateCloudDatabase) { _ in }
                self.performDBBackup(completion: { _ in })
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
                completion(false)
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
            guard let zoneID = zoneID else { completion(false); return }
            createZone(zoneID: zoneID) { success in completion(success) }
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
                case .success:
                    DevTools.Log.debug("Zone created: \(zoneID)", .business)
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
        fetchAllRecords(recordType: "AppVersion", resultsLimit: 1, database: publicCloudDatabase) { record in
            if let record = record {
                guard let storeVersion = record["store_version"] as? String,
                      let minimumVersion = record["minimum_version"] as? String else {
                    completion(.failure(AppErrors.genericError(devMessage: "Invalid record format")))
                    return
                }
                completion(.success(Model.AppVersion(storeVersion: storeVersion, minimumVersion: minimumVersion)))
            } else {
                completion(.failure(AppErrors.genericError(devMessage: "Not found")))
            }
        }
    }

    func performDBBackup(completion: @escaping (Bool) -> Void) {
        fetchAllRecords(recordType: "DBBackup", resultsLimit: 1, database: privateCloudDatabase) { [weak self] record in
            guard let self else { return }
            if let record = record {
                updateRecord(record: record, assets: CKRecord.dbBackupAssets(), database: privateCloudDatabase, completion: completion)
            } else {
                addNewRecord(recordType: "DBBackup", assets: CKRecord.dbBackupAssets(), database: privateCloudDatabase, completion: completion)
            }
        }
    }

    func fetchAllRecords(recordType: String, resultsLimit: Int = 1, database: CKDatabase, completion: @escaping (CKRecord?) -> Void) {
        iCloudIsAvailable { available in
            guard available else {
                completion(nil)
                return
            }
            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
            let operation = CKQueryOperation(query: query)
            operation.resultsLimit = resultsLimit
            var recordFound = false
            operation.recordMatchedBlock = { _, result in
                switch result {
                case .success(let record):
                    completion(record)
                    recordFound = true
                case .failure(let error):
                    DevTools.Log.error(error, .business)
                    completion(nil)
                }
            }
            operation.queryResultBlock = { operationResult in
                switch operationResult {
                case .success:
                    if !recordFound {
                        // No record found!
                        completion(nil)
                    }
                case .failure(let error):
                    DevTools.Log.error(error, .business)
                    completion(nil)
                }
            }
            database.add(operation)
        }
    }
    
    func updateRecord(record: CKRecord, details: [String: String] = [:], assets: [String: URL] = [:], database: CKDatabase, completion: @escaping (Bool) -> Void) {
        iCloudIsAvailable { [weak self] available in
            guard available else { completion(false); return }
            guard details.count + assets.count > 0 else { completion(false); return }
            record.bindWith(details: details, assets: assets)
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.qualityOfService = .background
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    DevTools.Log.debug("Record updated: \(record.recordType)", .business)
                case .failure(let error):
                    DevTools.Log.debug("Error updating: \(error)", .business)
                }
            }
            operation.completionBlock = {

            }
            database.add(operation)
        }
    }
    
    func addNewRecord(recordType: String, details: [String: String] = [:], assets: [String: URL] = [:], database: CKDatabase, completion: @escaping (Bool) -> Void) {
        iCloudIsAvailable { [weak self] available in
            guard available else { completion(false); return }
            guard let self = self else { completion(false); return }
            guard details.count + assets.count > 0 else { completion(false); return }
            guard let zoneID = zoneID else { completion(false); return }
            let record = CKRecord(recordType: recordType, zoneID: zoneID)
            record.bindWith(details: details, assets: assets)
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.qualityOfService = .background
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    DevTools.Log.debug("Record added: \(record.recordType)", .business)
                case .failure(let error):
                    DevTools.Log.debug("Error adding: \(error)", .business)
                }
            }
            database.add(operation)
        }
    }
}

public extension CKRecord {
    static func details(appLifeCycleEvent name: String) -> [String: String] {
        var userInfo: [String: String] = [:]
        userInfo["numberOfLogins"] = Common.UserDefaultsManager.numberOfLogins.description
        userInfo["version"] = Common.AppInfo.version
        var event: [String: String] = [:]
        event["name"] = name
        event["type"] = "AppLifeCycle"
        event["userInfo"] = userInfo.sorted(by: { $0.key > $1.key }).description
        return event
    }

    static func dbBackupAssets() -> [String: URL] {
        var assets: [String: URL] = [:]
        assets["databaseFile"] = DataBaseRepository.shared.databaseURL
        return assets
    }
    
    func bindWith(details: [String: String] = [:], assets: [String: URL] = [:]) {
        details.keys.forEach { key in
            self[key] = details[key]
        }
        assets.keys.forEach { key in
            if let fileURL = assets[key] {
                self[key] = CKAsset(fileURL: fileURL)
            }
        }
    }
}
