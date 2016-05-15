//
//  APITests.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import XCTest
@testable import WeatherAlert

class APITests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAPISetup() {
        // We need API class that can take appID as a parameter
        let api_inst = API(appID: "87007d2e2b7d6d780bc634854fb2feba")
        XCTAssertNotNil(api_inst.appID)
        
        // We need to have a convenience shared instance, with our appID key be default
        let api_shared = API.sharedInstance
        XCTAssertNotNil(api_shared.appID)
        
        // shared instance and local instance keys must be the same
        XCTAssertEqual(api_inst.appID, api_shared.appID)
        
        let api_second_inst = API(appID: "test")
        XCTAssertNotEqual(api_inst.appID, api_second_inst.appID)
        XCTAssertNotEqual(api_shared.appID, api_second_inst.appID)
    }

}
