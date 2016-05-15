//
//  API.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation

class API {
    
    static let sharedInstance = API(appID: "87007d2e2b7d6d780bc634854fb2feba")
    private(set) var appID: String!
    var serverURL: NSURL {
        return NSURL(string: "http://api.openweathermap.org/data/2.5")!
    }
    
    init(appID: String) {
        self.appID = appID
    }
    
}