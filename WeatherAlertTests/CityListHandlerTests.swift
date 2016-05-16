//
//  CitiesHandlerTests.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 14/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import XCTest
@testable import WeatherAlert
@testable import ObjectMapper
import CoreData

class CityListHandlerTests: XCTestCase {
    
    // It would be good idea to use shared instance across the app as we need to load cities list only once
    let cityList: CityList? = CityList.sharedInstance
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // city list will be nil if it failed to load file
        CDM.sharedInstance.deleteObjects(entityName: "CityWeather")
        CDM.sharedInstance.saveContext()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: CityList.sharedInstance.kCityListDidLoadCitiesToCoreDataKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        XCTAssertNotNil(cityList, "CityList failed to load from json file")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCityListLoadToCoreData() {
        
            let expectation = self.expectationWithDescription("Cities are loaded to core data from json file")
            self.cityList?.loadCitiesToCoreData { finished in
                XCTAssertTrue(finished, "There was an error storing all cities to core data")
                XCTAssertTrue(NSUserDefaults.standardUserDefaults().boolForKey(self.cityList!.kCityListDidLoadCitiesToCoreDataKey))
                
                let testFetch = NSFetchRequest(entityName: "CityWeather")
                testFetch.fetchLimit = 5
                let count = CDM.sharedInstance.managedObjectContext.countForFetchRequest(testFetch, error: nil)
                XCTAssertEqual(count, 5, "There must be 5 cities in fetch")
                
                do {
                    let results = try CDM.sharedInstance.managedObjectContext.executeFetchRequest(testFetch)
                    XCTAssertTrue(results is [CityWeather])
                    let firstCity = results.first as? CityWeather
                    XCTAssertNotNil(firstCity?.name)
                    XCTAssertNotNil(firstCity?.country)
                } catch let err as NSError {
                    XCTFail(err.description)
                }
                
                expectation.fulfill()
            }
            self.waitForExpectationsWithTimeout(30, handler: nil)
        
        
    }
    
    func testCityListLoading() {
        // citylist loading must happen in background as it's quite a big file.
        let expectation = self.expectationWithDescription("City list loaded into memory")
        self.cityList?.load { cities in
            
            XCTAssertNotNil(cities, "Cities object must not be nil, it seems json loading failed")
            XCTAssertGreaterThan(cities?.count ?? 0, 1, "There must be some cities in the list")
            
            let cityObj = cities?.first
            let city = City(jsonObject: cityObj ?? [:])
            XCTAssertEqual(city.id, 707860)
            XCTAssertEqual(city.name, "Hurzuf")
            XCTAssertEqual(city.country, "UA")
            
            let coord = city.coord
            XCTAssertEqual(coord?.lon, 34.283333)
            XCTAssertEqual(coord?.lat, 44.549999)
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testCityListSearch() {
        
        // load cities first
        var expectation = expectationWithDescription("DidLoad cities")
        cityList?.loadCitiesToCoreData { finished in
            
            XCTAssertTrue(finished, "There was an error storing all cities to core data")
            XCTAssertTrue(NSUserDefaults.standardUserDefaults().boolForKey(self.cityList!.kCityListDidLoadCitiesToCoreDataKey))

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(30, handler: nil)
    
        // Search for London
        expectation = expectationWithDescription("Did found cities matching pattern 'London'")
        self.cityList?.search(name: "London") { cities in
            XCTAssertGreaterThan(cities.count, 1, "There must be at least 1 city called London")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
        
        // Search for Vilnius
        expectation = expectationWithDescription("Did found cities matching pattern 'Vilnius'")
        self.cityList?.search(name: "Vilnius") { cities in
            XCTAssertNotNil(cities, "No cities found for search 'Vilnius'")
            XCTAssertEqual(cities.count, 1, "There should be 1 city named 'Vilnius'")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
        
        // search for 'ilniu' should result in 'Vilnius', no other city matches this pattern
        expectation = expectationWithDescription("Did found cities matching pattern 'ilniu'")
        cityList?.search(name: "ilniu") { cities in
            XCTAssertEqual(cities.count, 1, "There should be 1 city named 'ilniu'")
            let city = cities.first
            XCTAssertEqual(city?.name, "Vilnius")
            XCTAssertEqual(city?.country, "LT")
            XCTAssertEqual(city?.id, 593116)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
        
        // Search for some weird stuff
        expectation = expectationWithDescription("Did not found cities matching pattern 'some-random-stuff'")
        cityList?.search(name: "some-random-stuff") { cities in
            let count = cities.count
            XCTAssertEqual(count, 0, "Cities must be an empty array if no pattern found")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testCityObjectMapping() {
        let testCityJSON = "{\"_id\":707860,\"name\":\"Hurzuf\",\"country\":\"UA\",\"coord\":{\"lon\":34.283333,\"lat\":44.549999}}"
        let jsonObject = try! NSJSONSerialization.JSONObjectWithData(testCityJSON.dataUsingEncoding(NSUTF8StringEncoding)!, options: .MutableContainers)
        let city = City(jsonObject: jsonObject as! [String : AnyObject])
        XCTAssertNotNil(city)
        XCTAssertEqual(city.id, 707860)
        XCTAssertEqual(city.name, "Hurzuf")
        XCTAssertEqual(city.country, "UA")
        
        let coord = city.coord
        XCTAssertEqual(coord?.lon, 34.283333)
        XCTAssertEqual(coord?.lat, 44.549999)
        
    }
}
