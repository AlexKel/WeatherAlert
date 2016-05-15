//
//  CDExtensions.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation
import CoreData

/**
 *  This a protocol that `NSManagedObject` can implement to map with JSON object
 */
protocol JSONMappableManagedObject {
    func mapJSON(object: [String : AnyObject])
}

extension NSManagedObject {
    
    /**
     Initialise NSManagedObject with JSON Object
     
     - parameter object:  JSON Object
     - parameter context: Core data context
     
     - returns: NSManagedObject or nil
     */
    convenience init?(jsonObject object: [String : AnyObject], context: NSManagedObjectContext = CDM.sharedInstance.managedObjectContext) {
        if let className = NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last,  entityDescription = NSEntityDescription.entityForName(className, inManagedObjectContext: context) {
            self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
            if let mappable = self as? JSONMappableManagedObject {
                mappable.mapJSON(object)
            }
        } else {
            return nil
        }
    }
}
