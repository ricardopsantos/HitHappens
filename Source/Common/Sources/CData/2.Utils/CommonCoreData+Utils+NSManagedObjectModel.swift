//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// MARK: - NSManagedObjectModel
//

extension Bundle {
    static let spmBundle = Bundle(path: "\(Bundle.main.bundlePath)/resource/bundle")
}

private enum ManagedObjectModelCache {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var models: [URL: NSManagedObjectModel] = [:]

    /// One `NSManagedObjectModel` instance per model file. Loading the same .momd into several
    /// instances makes Core Data log "Failed to find a unique match for an NSEntityDescription
    /// to a managed object subclass" and entity-based APIs (`Entity(context:)`, `fetchRequest()`)
    /// can then resolve to the wrong model — e.g. `syncClearAll` silently deleting nothing.
    static func model(at url: URL) -> NSManagedObjectModel? {
        lock.lock(); defer { lock.unlock() }
        if let cached = models[url] { return cached }
        guard let model = NSManagedObjectModel(contentsOf: url) else { return nil }
        models[url] = model
        return model
    }
}

public extension CommonCoreData.Utils {
    static func managedObjectModel(
        dbName: String,
        dbBundle: String
    ) -> (managedObjectModel: NSManagedObjectModel, url: URL)? {
        guard let bundle = Bundle(identifier: dbBundle),
              let modelURL = bundle.url(forResource: dbName, withExtension: "momd"),
              let managedObjectModel = ManagedObjectModelCache.model(at: modelURL) else {
            return nil
        }
        return (managedObjectModel, modelURL)
    }

    /// When using SwiftPackage Manager
    /// Bundle.module is automatically generated for any package target that includes at least one resource.
    static func managedObjectModelForSPM(
        dbName: String
    ) -> (managedObjectModel: NSManagedObjectModel, url: URL)? {
        #if IN_PACKAGE_CODE
        guard let modelURL = Bundle.module.url(forResource: dbName, withExtension: "momd"),
              let managedObjectModel = ManagedObjectModelCache.model(at: modelURL) else {
            return nil
        }
        return (managedObjectModel, modelURL)
        #else
        return nil
        #endif
    }
}
