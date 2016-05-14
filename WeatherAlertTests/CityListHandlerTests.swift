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

class CityListHandlerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCityListLoading() {
        // intialise cityList from file
        let cityList = CityList(fileName: "")
        // city list will be nil if it failed to load file
        XCTAssertNotNil(cityList, "City list must not be nil");
        // We'll be getting cities in the background thread, so we'll need to wait for that to finish.
        let expectation = expectationWithDescription("Did load cities list")
        
        // Get all cities, just test that we can get cities
        cityList.getAll { (cities: [City], error: NSError?) in
            // There shouldn't be any errors
            XCTAssertNil(error, "There was an error getting cities from json file : \(error)")
            // There must some cities in the file
            XCTAssertGreaterThan(cities.count, 0, "There must be at least 1 city in the file")
            // Fullfill expectation
            expectation.fulfill()
        }
        
        // We'll allow 5 seconds to wait, as this read should be quite quick.
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testCityObjectMapping() {
        let testCityJSON = "{\"_id\":707860,\"name\":\"Hurzuf\",\"country\":\"UA\",\"coord\":{\"lon\":34.283333,\"lat\":44.549999}}"
        let city = Mapper<City>().map(testCityJSON)
        XCTAssertNotNil(city)
        XCTAssertEqual(city?.id, 707860)
        XCTAssertEqual(city?.name, "Hurzuf")
        XCTAssertEqual(city?.country, "UA")
        
        let coord = city?.coord
        XCTAssertEqual(coord?.lon, 34.283333)
        XCTAssertEqual(coord?.lat, 44.549999)
        
    }
}
