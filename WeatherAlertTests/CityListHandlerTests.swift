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
    
    func testCityListInitializer() {
        // intialise cityList from file
        let cityList = CityList(fileName: "city.list", newLineDelimited: true)

        // city list will be nil if it failed to load file
        XCTAssertNotNil(cityList, "City list must not be nil");
        
        let cities = cityList?.cities
        // at this point cities shouldn't be loaded
        XCTAssertNil(cities, "Cities should only be initialized when requested")
    }
    
    func testCityListLoading() {
        let cityList = CityList(fileName: "city.list", newLineDelimited: true)
        XCTAssertNotNil(cityList)
        
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
