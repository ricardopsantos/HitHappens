//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation
import CoreData
//
// NSFetchRequest Utils
//
public extension CDataTrackedEntity {
    typealias DBEntity = CDataTrackedEntity

    static var idFields: [String] { ["id"] }

    static func fetchRequestAll(sorted: Bool = false) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        if sorted {
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \DBEntity.favorite, ascending: true),
                NSSortDescriptor(keyPath: \DBEntity.name, ascending: true)
            ]
        }
        return request
    }

    /// Filtering is pushed down to the store (SQLite) via predicates instead of
    /// fetching all records and filtering in memory.
    static func fetchRequestWith(favorite: Bool?, archived: Bool?) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        var predicates: [NSPredicate] = []
        if let favorite = favorite {
            predicates.append(NSPredicate(format: "favorite == %@", NSNumber(value: favorite)))
        }
        if let archived = archived {
            predicates.append(NSPredicate(format: "archived == %@", NSNumber(value: archived)))
        }
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        return request
    }

    static func fetchRequestWith(id: String) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        request.predicate = NSPredicate.anyField(DBEntity.idFields, with: id)
        request.fetchLimit = 1
        return request
    }
}
