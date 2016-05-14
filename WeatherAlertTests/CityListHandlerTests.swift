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
    
    var cityList: CityList?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cityList = CityList(fileName: "city.list", newLineDelimited: true)
        // city list will be nil if it failed to load file
        XCTAssertNotNil(cityList, "CityList failed to load from json file")
        
        let cities = cityList?.cities
        // at this point cities shouldn't be loaded
        XCTAssertNil(cities, "Cities should only be initialized when requested")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCityListLoading() {
    
        let expectation = expectationWithDescription("City list loaded into memory")
        // citylist loading must happen in background as it's quite a big file.
        cityList?.load { cities in
            
            XCTAssertNotNil(cities, "Cities object must not be nil, it seems json loading failed")
            XCTAssertGreaterThan(cities!.count, 0, "There must be some cities in the list")
            
            let city = cities?.first
            XCTAssertEqual(city?.id, 707860)
            XCTAssertEqual(city?.name, "Hurzuf")
            XCTAssertEqual(city?.country, "UA")
            
            let coord = city?.coord
            XCTAssertEqual(coord?.lon, 34.283333)
            XCTAssertEqual(coord?.lat, 44.549999)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testCityListSearch() {
        cityList.search(name: "London") { cities in
            XCTAssertNotNil(cities, "No cities found for test search 'London'")
            XCTAssertGreaterThan(cities.count, 0, "There must be at least 1 city called London")
        }
        
        cityList.search(name: "Vilnius", country: "LT") { cities in
            XCTAssertNotNil(cities, "No cities found for search 'Vilnius'")
            XCTAssertEqual(cities.count, 1, "There should be 1 city named 'Vilnius'")
        }
        
        // search for 'ilniu' should result in 'Vilnius', no other city matches this pattern
        cityList.search(name: "ilniu") { cities in
            XCTAssertNotNil(cities, "No cities found for search 'ilniu'")
            XCTAssertEqual(cities.count, 1, "There should be 1 city named 'ilniu'")
            let city = cities.first
            XCTAssertEqual(city.name, "Vilnius")
            XCTAssertEqual(city.country, "LT")
            XCTAssertEqual(city.id, 593116)
        }
        
        cityList.search(name: "some-random-stuff") { cities in
            XCTAssertNil(cities, "Cities must be nil if no pattern found")
        }
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
