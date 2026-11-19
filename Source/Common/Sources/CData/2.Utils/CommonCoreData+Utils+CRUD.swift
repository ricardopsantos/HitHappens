//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// MARK: - Utils CRUD operations
//

public extension CommonCoreData.Utils {
    @discardableResult
    static func batchDelete(
        context: NSManagedObjectContext,
        request: NSFetchRequest<NSFetchRequestResult>
    ) -> Bool {
        do {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            // A batch delete runs on the store and bypasses the context, so the deleted objects
            // must be merged back or the context keeps serving the stale (deleted) rows.
            deleteRequest.resultType = .resultTypeObjectIDs
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            if let deletedIDs = result?.result as? [NSManagedObjectID], !deletedIDs.isEmpty {
                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: [NSDeletedObjectsKey: deletedIDs],
                    into: [context]
                )
            }
            try context.save()
            try context.parent?.save()
            return true
        } catch {
            context.rollback()
            Common_Logs.error("Couldn't delete the entities " + error.localizedDescription)
            return false
        }
    }

    @discardableResult
    /// Saves the context, at the same time it prints debug messages
    static func save(viewContext: NSManagedObjectContext?) -> Bool {
        guard let viewContext, viewContext.hasChanges else {
            return false
        }
        var saveSuccess = false
        let threadInfo: String = (Thread.isMain ? "Main" : "Background") + " Thread"
        var changes = ""
        #if DEBUG
        if !viewContext.insertedObjects.isEmpty {
            let relatedObjects = viewContext.insertedObjects
            let className = relatedObjects.first?.entity.name ?? ""
            changes = "# Inserted \(relatedObjects.count) of \(className)"
        }
        if !viewContext.deletedObjects.isEmpty {
            let relatedObjects = viewContext.deletedObjects
            let className = relatedObjects.first?.entity.name ?? ""
            changes = "# Deleted \(relatedObjects.count) of \(className)"
        }
        if !viewContext.updatedObjects.isEmpty {
            let relatedObjects = viewContext.updatedObjects
            let className = relatedObjects.first?.entity.name ?? ""
            changes = "# Updated \(relatedObjects.count) of \(className)"
        }
        #endif
        switch viewContext.concurrencyType {
        case .privateQueueConcurrencyType, .confinementConcurrencyType:
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = viewContext
            privateContext.performAndWait { [weak viewContext, weak privateContext] in
                do {
                    try privateContext?.save()
                    try viewContext?.save()
                    saveSuccess = true
                } catch {
                    viewContext?.rollback()
                    let nserror = error as NSError
                    Common_Logs.error("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        case .mainQueueConcurrencyType:
            do {
                try viewContext.save()
                if let parent = viewContext.parent, parent.hasChanges {
                    try parent.save()
                }
                saveSuccess = true
            } catch {
                viewContext.rollback()
                let nserror = error as NSError
                Common_Logs.error("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        @unknown default:
            ()
        }
        if logsEnabled, !changes.isEmpty, !Common.Utils.onUITests /* , !Common.Utils.onUnitTests */ {
            Common_Logs.debug(" 💾 \(changes) @ \(threadInfo)") }
        return saveSuccess
    }
}
