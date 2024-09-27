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
public class DataBaseRepository: DataBaseRepositoryProtocol {
    public func emit(event: OutputType) {
        
    }
    
    public func output(_ filter: [OutputType]) -> AnyPublisher<OutputType, Never> {
        .empty()
    }
    
    public static func emit(event: OutputType) {
        
    }
    
    public static func output(_ filter: [OutputType]) -> AnyPublisher<OutputType, Never> {
        .empty()
    }
    
    public static var shared = DataBaseRepository()
    fileprivate let persistentContainer: NSPersistentContainer?

    var viewContext: NSManagedObjectContext {
        let context = persistentContainer!.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    private init() {
        let bundle = Bundle(identifier: Domain.bundleIdentifier)!
        let modelURL = bundle.url(forResource: Domain.internalDB, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
          
        self.persistentContainer = NSPersistentCloudKitContainer(
            name: Domain.internalDB,
            managedObjectModel: managedObjectModel
        )
        persistentContainer?.loadPersistentStores { _, error in
            if let error {
                Common_Logs.error("Unresolved error \(error), \(error.localizedDescription)")
            }
        }

    }
    
    /*
    public static var shared = DataBaseRepository(
        dbName: Domain.internalDB,
        dbBundle: Domain.bundleIdentifier,
        persistence: Domain.coreDataPersistence
    )
    

    override private init(dbName: String, dbBundle: String, persistence: CommonCoreData.Utils.Persistence) {
        super.init(dbName: dbName, dbBundle: dbBundle, persistence: persistence)
    }

    public func reloadDatabase(url: URL) {
        replaceDatabase(newDatabaseURL: url)
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
    }*/
}
