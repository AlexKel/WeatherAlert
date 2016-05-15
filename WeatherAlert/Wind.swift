//
//  Wind.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation
import CoreData


class Wind: NSManagedObject, JSONMappableManagedObject {

// Insert code here to add functionality to your managed object subclass

    func mapJSON(object: [String : AnyObject]) {
        speed = object["speed"] as? Double
        deg = object["deg"] as? Double
    }
    
}
