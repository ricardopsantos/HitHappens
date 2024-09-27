//
//  DataBaseRepository.swift
//  Core
//
//  Created by Ricardo Santos on 21/08/2024.
//

import Foundation
import CoreData
import Combine
//
import Common
import Domain
public class DataBaseRepository2: CommonBaseCoreDataManager {
    
}
public class DataBaseRepository: CommonBaseCoreDataManager, DataBaseRepositoryProtocol {

    public static var shared = sharedV1
    public static var sharedV1 = DataBaseRepository(
        dbName: Domain.internalDB,
        dbBundle: Domain.bundleIdentifier,
        persistence: Domain.coreDataPersistence
    )
    public static var sharedV2 = DataBaseRepository()

    private init() {
        let bundle = Bundle(identifier: Domain.bundleIdentifier)!
        let modelURL = bundle.url(forResource: Domain.internalDB, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        super.init(dbName: Domain.internalDB, 
                   managedObjectModel: managedObjectModel,
                   persistence:  Domain.coreDataPersistence)
    }
    
    override private init(dbName: String, dbBundle: String, persistence: CommonCoreData.Utils.Persistence) {
        super.init(dbName: dbName, dbBundle: dbBundle, persistence: persistence)
    }

    override public func startFetchedResultsController() {
        guard fetchedResultsController.isEmpty else {
            return
        }

        // Create the controller with specific type
        fetchedResultsController["\(CDataTrackedLog.self)"] = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: CDataTrackedLog.fetchRequestAll(sorted: true) as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController["\(CDataTrackedEntity.self)"] = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: CDataTrackedEntity.fetchRequestAll(sorted: true) as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController.forEach { _, controller in
            controller.delegate = self
            try? controller.performFetch()
        }
    }
}
