//
//  CityList.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 14/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class CityList {
    
    private(set) var cities: [City]?
    private(set) var fileName: String
    private var jsonString: String?
    
    
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
    
    func load(completion: ((cities: [City]?)->())?) {
        guard cities == nil else {
            completion?(cities: cities)
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] in
            self?.cities = Mapper<City>().mapArray(self?.jsonString)
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                completion?(cities: self?.cities)
            })
        })
    }
}