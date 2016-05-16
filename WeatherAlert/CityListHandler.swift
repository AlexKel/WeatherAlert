//
//  CityList.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 14/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData
import RNActivityView



/// CityList holds a list of cities loaded from the local json file provided by Open Weather
class CityList {
    static let sharedInstance = CityList(fileName: "city.list", newLineDelimited: true)!
    private(set) var cities: [[String : AnyObject]] = []
    private(set) var fileName: String
    private var jsonString: String?
    private let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    let kCityListDidLoadCitiesToCoreDataKey = "CityListDidLoadCitiesToCoreDataKey"
    
    /**
     Initialises `CityList` with given file name
     
     - parameter fileName:         Name of the file in app resources
     - parameter newLineDelimited: Default is `false`. Open Weather provides JSON file in newline delimited JSON format.
     
     - returns: `CityList` instance or `nil` if failed to load from json file
     */
    init?(fileName: String, newLineDelimited: Bool = false) {
        self.fileName = fileName
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")
        do {
            let data = try NSData(contentsOfFile: filePath!, options: .DataReadingMappedIfSafe)
            jsonString = String(data: data, encoding: NSUTF8StringEncoding)
            if newLineDelimited == true && jsonString != nil {
                // As NSJSONSerialisation doesn't support newline delimited JSON - add commas and
                jsonString = String(format: "[%@]", jsonString!.stringByReplacingOccurrencesOfString("\n", withString: ","))
            }
        } catch let error as NSError {
            print("Could not load json file named: \(fileName). Error: \(error)")
            return nil
        }
    }
    
    /**
     Loads cities into memory in background thread
     
     - parameter completion: This block is called when parsing of JSON file finishes and provides a list of cities to work with
     */
    @available(*, unavailable, message="Really bad performance with large JSON file, database is now pre-populated and stored as a resource")
    func load(completion: ((cities: [[String : AnyObject]]?)->())?) {
        dispatch_async(backgroundQueue, { [weak self] in
            do {
                self?.cities.removeAll()
                
                let jsonObject = try NSJSONSerialization.JSONObjectWithData(self!.jsonString!.dataUsingEncoding(NSUTF8StringEncoding)!, options: .MutableContainers)
                if let arr = jsonObject as? [[String : AnyObject]] {
                    self?.cities = arr
                }
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    completion?(cities: self?.cities)
                    })
            } catch {
                dispatch_async(dispatch_get_main_queue(), {
                    completion?(cities: nil)
                })
            }
        })
    }
    
    /**
     New, impoved performance method. Stores cities into core data, from where we should fetch later
     
     - parameter completion: Block is called on completion. `finished` is `true` if there were no errors
     */
    @available(*, unavailable, message="Really bad performance with large JSON file, database is now pre-populated and stored as a resource")
    func loadCitiesToCoreData(completion:((finished: Bool) -> ())?) {
        guard self.jsonString != nil else {
            completion?(finished: false)
            return
        }
        guard NSUserDefaults.standardUserDefaults().boolForKey(kCityListDidLoadCitiesToCoreDataKey) == false else {
            // already been loaded previously
            completion?(finished: true)
            return
        }
        
        dispatch_async(backgroundQueue, { [unowned self] in
            self.beginBackgroundTask()
            do {
                let jsonObject = try NSJSONSerialization.JSONObjectWithData(self.jsonString!.dataUsingEncoding(NSUTF8StringEncoding)!, options: .MutableContainers)
                if let arr = jsonObject as? [[String : AnyObject]] {
                    let tempContext = CDM.sharedInstance.temporaryContext()
                    tempContext.performBlockAndWait{
                        for obj in arr {
                           CityWeather(jsonObject: obj, context: tempContext)
                        }
                        
                        //save temp context
                        do {
                            try tempContext.save()
                        } catch {
                            let nserror = error as NSError
                            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                            dispatch_async(dispatch_get_main_queue(), {
                                self.endBackgroundTask()
                                completion?(finished: false)
                            })
                            return
                        }
                        
                        CDM.sharedInstance.managedObjectContext.performBlockAndWait{
                            do {
                                try CDM.sharedInstance.managedObjectContext.save()
                            } catch {
                                // Replace this implementation with code to handle the error appropriately.
                                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                let nserror = error as NSError
                                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                                abort()
                            }
                            
                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: self.kCityListDidLoadCitiesToCoreDataKey)
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.endBackgroundTask()
                            completion?(finished: true)
 
                        }
                    }
                    
                }
            } catch let err as NSError {
                dispatch_async(dispatch_get_main_queue(), {
                    NSLog("Unresolved error \(err), \(err.userInfo)")
                    self.endBackgroundTask()
                    completion?(finished: false)
                })
            }
          
        })
        
    }
    
    /**
     Searches for a city from a list loaded in memory
     
     - parameter searchName: text to search for
     - parameter completion: results are passed to this block on completion
     */
    func search(name searchName: String, completion: (cities: [CityWeather])->()) {
        
        let fetch = NSFetchRequest(entityName: "CityWeather")
        fetch.predicate = NSPredicate(format: "name contains[c] %@", searchName)
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetch.fetchLimit = 50
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (asynchronousFetchResult) -> Void in
            if let cities = asynchronousFetchResult.finalResult as? [CityWeather] {
                completion(cities: cities)
            } else {
                completion(cities: [])
            }
        }
        
        do {
            // Execute Asynchronous Fetch Request
            try CDM.sharedInstance.managedObjectContext.executeRequest(asynchronousFetchRequest)
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }

    }
    
    private func beginBackgroundTask() {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            [unowned self] in
            self.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    private func endBackgroundTask() {
        NSLog("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
}