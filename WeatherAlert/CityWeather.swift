//
//  CityWeather.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation
import CoreData


class CityWeather: NSManagedObject, JSONMappableManagedObject {

// Insert code here to add functionality to your managed object subclass
    func mapJSON(object: [String : AnyObject]) {
        dt = object["dt"] as? Int
        name = object["name"] as? String
        id = object["id"] as? Int
        if let weatherArray = object["weather"] as? [[String : AnyObject]], weather = weatherArray.first {
            self.weather = Weather(jsonObject: weather)
        }
        
        if let windObject = object["wind"] as? [String : AnyObject] {
            wind = Wind(jsonObject: windObject)
        }
    }
}
