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

public class CloudKitService: CloudKitManager {
    private var backupsZone: CKRecordZone.ID?
    private var eventsZone: CKRecordZone.ID?
    private var databaseRecord: CKRecord?
    private var zonesCreated: Bool = false
    override open func loggerEnabled() -> Bool {
        true
    }

    override public init(cloudKit: String) {
        super.init(cloudKit: cloudKit)
        self.backupsZone = CKRecordZone.ID(zoneName: "backupsZone", ownerName: CKCurrentUserDefaultName)
        self.eventsZone = CKRecordZone.ID(zoneName: "eventsZone", ownerName: CKCurrentUserDefaultName)
    }
}

//
// MARK: - CloudKitServiceProtocol
//

extension CloudKitService: CloudKitServiceProtocol {
    public func appStarted() {
        iCloudIsAvailable { [weak self] available in
            guard available else {
                return
            }
            self?.createZones { [weak self] _ in
                guard let self = self else { return }
                self.insertRecord(
                    recordType: "Event",
                    details: details(appLifeCycleEvent: "appStarted"),
                    database: privateCloudDatabase,
                    zoneID: eventsZone
                ) { _ in }
                self.syncDatabase()
            }
        }
    }

    public func syncDatabase() {
        iCloudIsAvailable { [weak self] available in
            guard let self = self else { return }
            guard available else {
                return
            }
            let recordType = "DBBackup"
            let assets = dbBackupAssets()
            createZones { [weak self] _ in
                guard let self = self else { return }
                if let databaseRecord = databaseRecord {
                    // 1 - Upload DB
                    updateRecord(
                        record: databaseRecord,
                        assets: assets,
                        database: privateCloudDatabase,
                        completion: { [weak self] _ in
                            // 2 - Refresh current database record
                            guard let self = self else { return }
                            fetchAllRecords(recordType: recordType, resultsLimit: 1, database: privateCloudDatabase) { [weak self] record in
                                guard let self else { return }
                                if let record = record {
                                    self.databaseRecord = record
                                }
                            }
                        }
                    )
                } else {
                    // No local databaseRecord. fetch it
                    fetchAllRecords(recordType: recordType, resultsLimit: 1, database: privateCloudDatabase) { [weak self] record in
                        guard let self else { return }
                        if let record = record {
                            databaseRecord = record
                            updateRecord(record: record, assets: assets, database: privateCloudDatabase, completion: { _ in })
                        } else {
                            insertRecord(
                                recordType: recordType,
                                assets: assets,
                                database: privateCloudDatabase,
                                zoneID: backupsZone,
                                completion: { _ in }
                            )
                        }
                    }
                }
            }
        }
    }

    public func applicationDidEnterBackground() {
        iCloudIsAvailable { [weak self] available in
            guard available else {
                return
            }
            self?.createZones { [weak self] _ in
                guard let self = self else { return }
                self.insertRecord(
                    recordType: "Event",
                    details: details(appLifeCycleEvent: "applicationDidEnterBackground"),
                    database: privateCloudDatabase,
                    zoneID: eventsZone
                ) { _ in }
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
                self.insertRecord(
                    recordType: "Event",
                    details: details(appLifeCycleEvent: "appDidFinishLaunchingWithOptions"),
                    database: privateCloudDatabase,
                    zoneID: eventsZone
                ) { _ in }
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
// MARK: - Auxiliar
//

private extension CloudKitService {
    func details(appLifeCycleEvent name: String) -> [String: String] {
        var userInfo: [String: String] = [:]
        userInfo["number_of_logins"] = Common.UserDefaultsManager.numberOfLogins.description
        userInfo["version"] = Common.AppInfo.version
        var event: [String: String] = [:]
        event["name"] = name
        event["type"] = "AppLifeCycle"
        event["user_info"] = userInfo.sorted(by: { $0.key > $1.key }).description
        return event
    }

    func dbBackupAssets() -> [String: URL] {
        var assets: [String: URL] = [:]
        assets["databaseFile"] = DataBaseRepository.shared.databaseURL
        return assets
    }

    func createZones(completion: @escaping (Bool) -> Void) {
        guard !zonesCreated else { completion(false); return }
        iCloudIsAvailable { [weak self] available in
            guard available else { completion(false); return }
            guard let self = self else { completion(false); return }
            guard let backupsZone = backupsZone else { completion(false); return }
            guard let eventsZone = eventsZone else { completion(false); return }
            createZone(zoneID: backupsZone) { [weak self] success in
                guard success else { completion(false); return }
                self?.createZone(zoneID: eventsZone) { [weak self] success in
                    self?.zonesCreated = success
                    completion(success)
                }
            }
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
}
