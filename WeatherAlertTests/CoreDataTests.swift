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
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
   
    func testCityWeatherStoring() {
        
        let coreDataManager = CDM()
        let fetch = NSFetchRequest(entityName: "CityWeather")
        var error: NSError?
        var count = coreDataManager.managedObjectContext.countForFetchRequest(fetch, error: &error)
        XCTAssertEqual(count, 0, "There shouldn't be any CityWeather objects in core data from the start")
        
        let cityWeather = NSEntityDescription.insertNewObjectForEntityForName("CityWeather", inManagedObjectContext: coreDataManager.managedObjectContext)
        cityWeather.setValuesForKeysWithDictionary(cityWeatherObjectJSONString!)
        XCTAssertTrue(cityWeather is CityWeather, "Inserted object isn't a CityWather object")
        XCTAssertEqual(cityWeather.name, "London")
        XCTAssertEqual(cityWeather.id, 2643743)
        XCTAssertNotNil(cityWeather.weather)
        let currentWeather = weather.first as? Weather
        XCTAssertNotNil(currentWeather)
        XCTAssertEqual(currentWeather.id, "800")
        XCTAssertEqual(currnetWeather.main, "Clear")
        XCTAssertEqual(currentWeather.description, "clear sky")
        XCTAssertEqual(currentWeather.icon, "01d")
        let wind = cityWeather.wind as? Wind
        XCTAssertNotNil(wind)
        XCTAssertEqual(wind.speed, 4.07)
        XCTAssertEqual(wind.deg, 308)
        XCTAssertEqual(cityWeather.dt, 1463308797)
        

    }
    
    
}
