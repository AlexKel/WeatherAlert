//
//  CityList.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 14/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation


class CityList {
    
    private var cities: [City] = []
    
    init(fileName: String) {
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")
        do {
            let data = try NSData(contentsOfFile: filePath!, options: .DataReadingMappedIfSafe)
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
            
        } catch let error as NSError {
            print("Could not load json file named: \(fileName). Error: \(error)")
        }
    }
    
    func getAll(completion: (cities: [City], error: NSError?)->()) {
        completion(cities: cities, error: nil)
    }
    
}