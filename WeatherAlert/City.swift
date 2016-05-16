//
//  City.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 14/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class City : JSONMappableManagedObject {
    
    var id: Int?
    var name: String?
    var country: String?
    var coord: Coord?
    
    init(jsonObject: [String : AnyObject]){
        mapJSON(jsonObject)
    }
    
    func mapJSON(object: [String : AnyObject]) {
        id = object["_id"] as? Int
        name = object["name"] as? String
        country = object["country"] as? String
        if let coord = object["coord"] as? [String : AnyObject] {
            self.coord = Coord(jsonObject: coord)
        }
    }
}

class Coord : JSONMappableManagedObject {
    
    var lon: Double?
    var lat: Double?
    
    func mapJSON(object: [String : AnyObject]) {
        lon = object["lon"] as? Double
        lat = object["lat"] as? Double
    }
    
    init(jsonObject: [String : AnyObject]) {
        mapJSON(jsonObject)
    }
}