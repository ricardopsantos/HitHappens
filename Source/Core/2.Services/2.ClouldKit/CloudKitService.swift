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

public class CloudKitService {
    private let container: CKContainer
    private let publicCloudDatabase: CKDatabase
    private let privateCloudDatabase: CKDatabase
    public var zoneID: CKRecordZone.ID?

    public init(cloudKit: String) {
        self.container = CKContainer(identifier: cloudKit)
        self.publicCloudDatabase = container.publicCloudDatabase
        self.privateCloudDatabase = container.privateCloudDatabase
        self.zoneID = CKRecordZone.ID(zoneName: "\(Self.self).user.zone", ownerName: CKCurrentUserDefaultName)
    }
}

//
// MARK: - Private
//

//
// MARK: - CloudKitServiceProtocol
//

extension CloudKitService: CloudKitServiceProtocol {
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

    public func fetchAppVersion(completion: @escaping (Result<Model.AppVersion, Error>) -> Void) {
        iCloudIsAvailable { [weak self] available in
            guard available else {
                completion(.failure(AppErrors.genericError(devMessage: "iCloud not available")))
                return
            }
            guard let self = self else { return }
            let query = CKQuery(recordType: "AppVersion", predicate: NSPredicate(value: true))
            let queryOperation = CKQueryOperation(query: query)
            queryOperation.resultsLimit = 1
            queryOperation.recordMatchedBlock = { _, result in
                switch result {
                case .success(let record):
                    guard let storeVersion = record["store_version"] as? String,
                          let minimumVersion = record["minimum_version"] as? String else {
                        completion(.failure(AppErrors.genericError(devMessage: "Invalid record format")))
                        return
                    }
                    completion(.success(Model.AppVersion(storeVersion: storeVersion, minimumVersion: minimumVersion)))
                case .failure(let error):
                    DevTools.Log.error(error, .business)
                    completion(.failure(error))
                }
            }
            publicCloudDatabase.add(queryOperation)
        }
    }
}

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

    func createZone(completion: @escaping (Error?) -> Void) {
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
                    completion(nil)
                case .failure(let error):
                    DevTools.Log.error("Error creating zone: \(error)", .business)
                    completion(error)
                }
            }
            operation.qualityOfService = .utility
            privateCloudDatabase.add(operation)
        }
    }

    func writeEvent(name: String, completion: @escaping (Error?) -> Void) {
        iCloudIsAvailable { [weak self] available in
            guard available else { return }
            guard let self = self else { return }
            guard let zoneID = zoneID else { return }
            let recordType = "Event"
            let record = CKRecord(recordType: recordType, zoneID: zoneID)
            record["name"] = name
            record["date"] = Date()
            let saveOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            saveOperation.modifyRecordsResultBlock = { result in
                switch result {
                case .success(let record):
                    DevTools.Log.debug("Record saved successfully in custom zone \(record)", .business)
                case .failure(let error):
                    DevTools.Log.error("Error saving record: \(error)", .business)
                }
            }
            publicCloudDatabase.add(saveOperation)
        }
    }
}
