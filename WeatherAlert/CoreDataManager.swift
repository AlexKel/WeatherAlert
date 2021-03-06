//
//  CoreDataManager.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation
import CoreData

/// Core Data Manager
class CDM {
    
    static let sharedInstance = CDM()
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.motionly.WeatherAlert" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("WeatherAlert", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(url.path!) == false {
            if let preloadedStoreURL = NSBundle.mainBundle().URLForResource("SingleViewCoreData_preloaded", withExtension: ".sqlite") {
                do {
                    try fileManager.copyItemAtURL(preloadedStoreURL, toURL: url)
                } catch let err as NSError {
                    NSLog("Unresolved error \(err), \(err.userInfo)")
                }
            }
        }
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func temporaryContext() -> NSManagedObjectContext {
        let ctx = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        ctx.parentContext = managedObjectContext
        return ctx
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    // MARK: - Core data deletion of objects
    /**
     Delete objects with specified entity name
     
     - parameter names: a list of entity names to delete
     - note: We have to use old way in order to support iOS 8.. iOS 9 has a nice API for this stuff
     */
    func deleteObjects(entityName names: String...) {
        for name in names {
            let fetch = NSFetchRequest(entityName: name)
            do {
                let items = try managedObjectContext.executeFetchRequest(fetch)
                for obj in items {
                    managedObjectContext.deleteObject(obj as! NSManagedObject)
                }
            } catch let err as NSError{
                print("failed to delete objects for entity name: \(name). Error: \(err)")
            }
        }
    }
    
    func deleteDatabase() {
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        do {
            try NSFileManager.defaultManager().removeItemAtPath(url.path!)
        } catch let nserror as NSError {
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    // MARK: - Convenience
    func getFavouriteCities() -> [CityWeather] {
        var result: [CityWeather] = []
        
        let fetch = NSFetchRequest(entityName: "CityWeather")
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetch.predicate = NSPredicate(format: "favourite == %@", true)
        
        do {
            if let queryResults = try managedObjectContext.executeFetchRequest(fetch) as? [CityWeather] {
                result = queryResults
            }
        } catch let err as NSError {
            NSLog("Unresolved error \(err), \(err.userInfo)")
        }
        
        return result
    }
    

}