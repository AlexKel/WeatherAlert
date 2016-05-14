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
    static let sharedInstance = CityList(fileName: "city.list", newLineDelimited: true)
    private(set) var cities: [City]?
    private(set) var fileName: String
    private var jsonString: String?
    private let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    
    
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
        
        dispatch_async(backgroundQueue, { [weak self] in
            self?.cities = Mapper<City>().mapArray(self?.jsonString)
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                completion?(cities: self?.cities)
            })
        })
    }
    
    func search(name searchName: String, country: String? = nil, completion: (cities: [City])->()) {
        guard cities != nil else {
            completion(cities: [])
            return
        }
        
        dispatch_async(backgroundQueue, {
            let searchResult = self.cities!.filter({
                if let name = $0.name {
                    return name.localizedCaseInsensitiveContainsString(searchName)
                }
                return false
            })
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(cities: searchResult)
            })
        })
    }
}