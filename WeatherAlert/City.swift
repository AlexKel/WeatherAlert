//
//  City.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 14/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class City : Mappable{
    
    var id: Int?
    var name: String?
    var country: String?
    var coord: Coord?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        id      <- map["_id"]
        name    <- map["name"]
        country <- map["country"]
        coord   <- map["coord"]
    }
}

class Coord : Mappable {
    
    var lon: Double?
    var lat: Double?
    
    required init?(_ map: Map) {
        
    }
    
    
    func mapping(map: Map) {
        lon <- map["lon"]
        lat <- map["lat"]
    }
}