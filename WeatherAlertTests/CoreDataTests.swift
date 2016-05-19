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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // clear core data after testing
        super.tearDown()
    }
    
   
    func testCityWeatherStoring() {
        let coreDataManager = CDM()
        let fetch = NSFetchRequest(entityName: "CityWeather")
        let id: Int = 0
        fetch.predicate = NSPredicate(format: "id == %d", id)
        var error: NSError?
        var count = coreDataManager.managedObjectContext.countForFetchRequest(fetch, error: &error)
        XCTAssertEqual(count, 0, "There should be a CityWeather object in core data with id 922337203685")
        
        // then insert it again
        var cityWeather = CityWeather(jsonObject: cityWeatherObjectJSONString!, context: coreDataManager.managedObjectContext)
        
        XCTAssertNotNil(cityWeather, "Inserted object isn't a CityWather object")
        XCTAssertEqual(cityWeather?.name, "London")
        XCTAssertEqual(cityWeather?.id, id)
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
        
        coreDataManager.saveContext()
        count = coreDataManager.managedObjectContext.countForFetchRequest(fetch, error: &error)
        
        XCTAssertEqual(count, 1, "There must be 1 CityWather object")
        // Check fetch
        do {
            let items = try coreDataManager.managedObjectContext.executeFetchRequest(fetch)
            
            cityWeather = items.first as? CityWeather
            XCTAssertNotNil(cityWeather, "Inserted object isn't a CityWather object")
            XCTAssertEqual(cityWeather?.name, "London")
            XCTAssertEqual(cityWeather?.id, id)
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
        if cityWeather != nil {
            coreDataManager.managedObjectContext.deleteObject(cityWeather!)
            coreDataManager.saveContext()
        } else {
            XCTFail("City weather object is nil!")
        }
        
        
        XCTAssertEqual(coreDataManager.managedObjectContext.countForFetchRequest(fetch, error: nil), 0)
        var req = NSFetchRequest(entityName: "Weather")
        req.predicate = NSPredicate(format: "cityWeather.id == %d", id)
        XCTAssertEqual(coreDataManager.managedObjectContext.countForFetchRequest(fetch, error: nil), 0)
        req = NSFetchRequest(entityName: "Wind")
        req.predicate = NSPredicate(format: "cityWeather.id == %d", id)
        XCTAssertEqual(coreDataManager.managedObjectContext.countForFetchRequest(fetch, error: nil), 0)
        
        
    }
}
