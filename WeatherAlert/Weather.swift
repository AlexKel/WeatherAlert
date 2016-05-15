//
//  Weather.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation
import CoreData


class Weather: NSManagedObject, JSONMappableManagedObject {

// Insert code here to add functionality to your managed object subclass
//    "id": 800,
//    "main": "Clear",
//    "description": "clear sky",
//    "icon": "01d"
    func mapJSON(object: [String : AnyObject]) {
        id = object["id"] as? Int
        main = object["main"] as? String
        desc = object["description"] as? String
        icon = object["icon"] as? String
    }
}
