//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// MARK: - NSPersistentContainer
//

public extension CommonCoreData.Utils {
    enum Persistence {
        case `default`(iCloudEnabled: Bool)
        case memory(iCloudEnabled: Bool)
        case directory(value: FileManager.SearchPathDirectory)
        case appGroup(identifier: String)

        /// Local-only version of a CloudKit-backed persistence, used as fallback when
        /// the CloudKit store fails to load (no iCloud account, missing entitlements, ...).
        var withICloudDisabled: Persistence? {
            switch self {
            case .default(iCloudEnabled: true): return .default(iCloudEnabled: false)
            case .memory(iCloudEnabled: true): return .memory(iCloudEnabled: false)
            default: return nil
            }
        }
    }
}

public extension CommonCoreData.Utils {
    static func buildPersistentContainer(
        dbName: String,
        managedObjectModel: NSManagedObjectModel,
        persistence: Persistence
    ) -> NSPersistentContainer? {
        let container = makeContainer(
            dbName: dbName,
            managedObjectModel: managedObjectModel,
            persistence: persistence
        )
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let loadError {
            Common_Logs.error("Unresolved error \(loadError), \(loadError.localizedDescription)")
            // A CloudKit-backed store can fail to load when iCloud is unavailable.
            // Retry with the equivalent local-only persistence so the app keeps
            // working (records are stored locally and CloudKit picks them up on a
            // future launch where iCloud is available again).
            if let localPersistence = persistence.withICloudDisabled {
                Common_Logs.debug("Retrying \(dbName) with iCloud disabled (local store only)")
                let fallback = makeContainer(
                    dbName: dbName,
                    managedObjectModel: managedObjectModel,
                    persistence: localPersistence
                )
                var fallbackError: Error?
                fallback.loadPersistentStores { _, error in
                    fallbackError = error
                }
                if let fallbackError {
                    Common_Logs.error("Unresolved error \(fallbackError), \(fallbackError.localizedDescription)")
                } else {
                    CommonCoreData.Utils.printDBReport(
                        dbName: dbName,
                        container: fallback,
                        managedObjectModel: managedObjectModel
                    )
                }
                return fallback
            }
        } else {
            CommonCoreData.Utils.printDBReport(
                dbName: dbName,
                container: container,
                managedObjectModel: managedObjectModel
            )
        }
        return container
    }

    private static func makeContainer(
        dbName: String,
        managedObjectModel: NSManagedObjectModel,
        persistence: Persistence
    ) -> NSPersistentContainer {
        var container: NSPersistentContainer!
        switch persistence {
        case .default(iCloudEnabled: let iCloudEnabled):
            if iCloudEnabled {
                container = NSPersistentCloudKitContainer(
                    name: dbName,
                    managedObjectModel: managedObjectModel
                )
            } else {
                container = NSPersistentContainer(name: dbName, managedObjectModel: managedObjectModel)
            }
            if let description = container.persistentStoreDescriptions.first {
                // NSPersistentCloudKitContainer turns on persistent history tracking, and once a
                // store file has it the file can't be reopened without it. Keep it always on so
                // the same store works whether iCloud is enabled or not (user signs in/out).
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                if !iCloudEnabled {
                    description.cloudKitContainerOptions = nil
                }
            }
        case .memory(iCloudEnabled: let iCloudEnabled):
            if iCloudEnabled {
                container = NSPersistentCloudKitContainer(
                    name: dbName,
                    managedObjectModel: managedObjectModel
                )
            } else {
                container = NSPersistentContainer(name: dbName, managedObjectModel: managedObjectModel)
            }
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        case .directory(value: let value):
            container = NSPersistentContainer(name: dbName, managedObjectModel: managedObjectModel)
            if let defaultStoreURL = FileManager.default.urls(for: value, in: .userDomainMask).first {
                let storeURL = defaultStoreURL.appendingPathComponent("\(dbName).sqlite")
                let description = NSPersistentStoreDescription(url: storeURL)
                container.persistentStoreDescriptions = [description]
            }
        case .appGroup(identifier: let identifier):
            container = NSPersistentContainer(
                name: dbName,
                managedObjectModel: managedObjectModel
            )
            if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) {
                let storeURL = sharedContainerURL.appendingPathComponent("\(dbName).sqlite")
                let description = NSPersistentStoreDescription(url: storeURL)
                container.persistentStoreDescriptions = [description]
            } else {
                Common_Logs.error("Fail to access appGroupIdentifier: \(String(describing: identifier))")
            }
        }
        return container
    }
}

//
// MARK: - NSPersistentContainer
//

public extension CommonCoreData.Utils {
    static func printDBReport(dbName: String, container: NSPersistentContainer, managedObjectModel: NSManagedObjectModel) {
        let tables = container.managedObjectModel.entitiesByName.keys.description
        let version = managedObjectModel.versionIdentifiers.description.replace("AnyHashable", with: "")
        if let persistentStoreURL = container.persistentStoreCoordinator.persistentStores.first?.url {
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: persistentStoreURL.path)
                if let fileSize = fileAttributes[.size] as? Int64 {
                    let fileSizeInMB = Double(fileSize) / (1024 * 1024)
                    let report = """
                    Loaded DataBase \(dbName)
                      • name: \(dbName)
                      • version: \(version)
                      • tables: \(tables)
                      • size: \(fileSizeInMB) MB
                    """
                    Common_Logs.debug("\(report)")
                }
            } catch {
                Common_Logs.error("\(error.localizedDescription)")
            }
        }
    }
}
