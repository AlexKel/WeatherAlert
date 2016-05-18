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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testCityListSearch() {
            
        // Search for London
        let expectation2 = expectationWithDescription("Did found cities matching pattern 'London'")
        self.cityList?.search(name: "London") { cities in
            XCTAssertGreaterThan(cities.count, 1, "There must be at least 1 city called London")
            expectation2.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
        
        // Search for Vilnius
        let expectation3 = expectationWithDescription("Did found cities matching pattern 'Vilnius'")
        self.cityList?.search(name: "Vilnius") { cities in
            XCTAssertNotNil(cities, "No cities found for search 'Vilnius'")
            XCTAssertEqual(cities.count, 1, "There should be 1 city named 'Vilnius'")
            expectation3.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
        
        // search for 'ilniu' should result in 'Vilnius', no other city matches this pattern
        let expectation4 = expectationWithDescription("Did found cities matching pattern 'ilniu'")
        cityList?.search(name: "ilniu") { cities in
            XCTAssertEqual(cities.count, 1, "There should be 1 city named 'ilniu'")
            let city = cities.first
            XCTAssertEqual(city?.name, "Vilnius")
            XCTAssertEqual(city?.country, "LT")
            XCTAssertEqual(city?.id, 593116)
            expectation4.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
        
        // Search for some weird stuff
        let expectation5 = expectationWithDescription("Did not found cities matching pattern 'some-random-stuff'")
        cityList?.search(name: "some-random-stuff") { cities in
            let count = cities.count
            XCTAssertEqual(count, 0, "Cities must be an empty array if no pattern found")
            expectation5.fulfill()
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
    
    func testCityListSearchOrdering() {
        var expectaion = expectationWithDescription("Did found cities for 'piran'")
        
        cityList?.search(name: "piran") { cities in
            XCTAssertGreaterThan(cities.count, 0)
            let first = cities.first
            XCTAssertEqual(first?.name, "Pirane")
            expectaion.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
        
        
        expectaion = expectationWithDescription("Did found cities for 'tri'")
        cityList?.search(name: "tri") { cities in
            XCTAssertGreaterThan(cities.count, 0)
            let first = cities.first
            XCTAssertEqual(first?.name, "Tri Duby")
            expectaion.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}
