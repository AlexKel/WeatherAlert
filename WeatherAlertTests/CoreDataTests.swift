//
//  CoreDataTests.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import WeatherAlert


class CoreDataTests: XCTestCase {
    
    var cityWeatherObjectJSONString: [String : AnyObject]?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let cityWeatherObjectPath = NSBundle(forClass: self.dynamicType).pathForResource("CityWeatherObject", ofType: "json"), data = NSData(contentsOfFile: cityWeatherObjectPath) {
            do {
                cityWeatherObjectJSONString = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String : AnyObject]
            } catch let error as NSError {
                print("Failed to load json file from CityWeatherObject.json. Error: ", error)
            }
        }
        XCTAssertNotNil(cityWeatherObjectJSONString, "Test json object CityWeatherObject failed to load")
        // Clean core data before testing
        CDM.sharedInstance.deleteObjects(entityName: "CityWeather", "Weather", "Wind")
        CDM.sharedInstance.saveContext()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // clear core data after testing
        CDM.sharedInstance.deleteObjects(entityName: "CityWeather", "Weather", "Wind")
        CDM.sharedInstance.saveContext()
        super.tearDown()
    }
    
   
    func testCityWeatherStoring() {
        let coreDataManager = CDM()
        let fetch = NSFetchRequest(entityName: "CityWeather")
        var error: NSError?
        var count = coreDataManager.managedObjectContext.countForFetchRequest(fetch, error: &error)
        XCTAssertEqual(count, 0, "There shouldn't be any CityWeather objects in core data from the start")
        
        
        var cityWeather = CityWeather(jsonObject: cityWeatherObjectJSONString!)
        XCTAssertNotNil(cityWeather, "Inserted object isn't a CityWather object")
        XCTAssertEqual(cityWeather?.name, "London")
        XCTAssertEqual(cityWeather?.id, 2643743)
        XCTAssertNotNil(cityWeather?.weather)
        
        var currentWeather = cityWeather?.weather
        XCTAssertNotNil(currentWeather)
        XCTAssertEqual(currentWeather?.id, 800)
        XCTAssertEqual(currentWeather?.main, "Clear")
        XCTAssertEqual(currentWeather?.desc, "clear sky")
        XCTAssertEqual(currentWeather?.icon, "01d")
        
        var wind = cityWeather?.wind
        XCTAssertNotNil(wind)
        XCTAssertEqual(wind?.speed, 4.07)
        XCTAssertEqual(wind?.deg, 308)
        XCTAssertEqual(cityWeather?.dt, 1463308797)
        
        CDM.sharedInstance.saveContext()
        count = coreDataManager.managedObjectContext.countForFetchRequest(fetch, error: &error)
        
        XCTAssertEqual(count, 1, "There must be 1 CityWather object")
        // Delete all items from core data
        // check they're gone
        do {
            let items = try CDM.sharedInstance.managedObjectContext.executeFetchRequest(fetch)
            
            cityWeather = items.first as? CityWeather
            XCTAssertNotNil(cityWeather, "Inserted object isn't a CityWather object")
            XCTAssertEqual(cityWeather?.name, "London")
            XCTAssertEqual(cityWeather?.id, 2643743)
            XCTAssertNotNil(cityWeather?.weather)
            
            currentWeather = cityWeather?.weather
            XCTAssertNotNil(currentWeather)
            XCTAssertEqual(currentWeather?.id, 800)
            XCTAssertEqual(currentWeather?.main, "Clear")
            XCTAssertEqual(currentWeather?.desc, "clear sky")
            XCTAssertEqual(currentWeather?.icon, "01d")
            
            wind = cityWeather?.wind
            XCTAssertNotNil(wind)
            XCTAssertEqual(wind?.speed, 4.07)
            XCTAssertEqual(wind?.deg, 308)
            XCTAssertEqual(cityWeather?.dt, 1463308797)
            
        } catch let error as NSError {
            XCTFail(error.localizedDescription)
        }
        
        // Delete CityWeather item, weather and wind items should cascade and be deleted automatically
        CDM.sharedInstance.managedObjectContext.deleteObject(cityWeather!)
        CDM.sharedInstance.saveContext()
        
        var req = NSFetchRequest(entityName: "CityWeather")
        XCTAssertEqual(CDM.sharedInstance.managedObjectContext.countForFetchRequest(req, error: nil), 0)
        req = NSFetchRequest(entityName: "Weather")
        XCTAssertEqual(CDM.sharedInstance.managedObjectContext.countForFetchRequest(req, error: nil), 0)
        req = NSFetchRequest(entityName: "Wind")
        XCTAssertEqual(CDM.sharedInstance.managedObjectContext.countForFetchRequest(req, error: nil), 0)
        
        
    }
}
