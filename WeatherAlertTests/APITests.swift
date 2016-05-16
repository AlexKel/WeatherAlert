//
//  APITests.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import XCTest
@testable import WeatherAlert
import OHHTTPStubs

class APITests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        OHHTTPStubs.removeAllStubs()
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
        
        XCTAssertEqual(api_shared.serverURL, NSURL(string: "http://api.openweathermap.org/data/2.5"))
    }
    
    func testURLSessionConfiguration() {
        let session = API.sharedInstance.getSession()
        let contentType = session.configuration.HTTPAdditionalHeaders?["Content-Type"]
        XCTAssertNotNil(contentType)
        XCTAssertEqual(contentType as? String, "application/json")
    }
    
    
    func testURLRequestHandler() {
        // for this test we'll be using different API
        let api = API(appID: "any")
        let testURL = NSURL(string: "http://headers.jsontest.com")!
        let request = NSURLRequest(URL: testURL)
        
        let testExpectation = expectationWithDescription("API can successfuly make request to pages with json response")
        
        api.handleURLRequest(request) { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            // respopnse must be a json decoded object for this request
            XCTAssertTrue(response is [String : AnyObject])
            testExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    
    func testURLRequestHandlerFailure() {
        let api = API(appID: "any")
        let testURL = NSURL(string: "http://google.com")!
        let request = NSURLRequest(URL: testURL)
        
        let testExpectation = expectationWithDescription("API can handle failures gracefully")
        
        api.handleURLRequest(request) { (response: AnyObject?, error: NSError?) in
            // as this url doesn't provides json response - we should see an error here
            XCTAssertNotNil(error)
            testExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testEndpoints() {
        let api = API.sharedInstance
        
        // Current weather
        let endpoint = Endpoints.GetCurrentWeather
        XCTAssertEqual(endpoint.function, APIFunction.Weather)
        XCTAssertEqual(endpoint.method, HTTPMethod.GET)
        let urlRequest = api.urlRequestForEndpoint(endpoint)
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.URL, NSURL(string: "http://api.openweathermap.org/data/2.5/weather"))
        XCTAssertEqual(urlRequest?.HTTPMethod, "GET")
        
    }
    
    
    func testEndpointWithParams() {
        let params = [
            "id" : 2643743,
            "name" : "London"
        ]
        
        let api = API.sharedInstance
        let endpoint = Endpoints.GetCurrentWeather
        let urlRequest = api.urlRequestForEndpoint(endpoint, params: params)
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.URL, NSURL(string: "http://api.openweathermap.org/data/2.5/weather?id=2643743&name=London&APPID=\(api.appID)"))
        XCTAssertEqual(urlRequest?.HTTPMethod, "GET")
    }
    
    func testGetCurrentWeatherForCityWithID() {
        // Stub get current weather response
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return request.URL!.absoluteString.containsString("http://api.openweathermap.org/data/2.5/weather")
            }, withStubResponse: { _ in
                let testResponseFilePath = NSBundle(forClass: self.dynamicType).pathForResource("CityWeatherObject", ofType: "json")!
                let stubResponse = OHHTTPStubsResponse(fileAtPath: testResponseFilePath, statusCode: 200, headers: ["Content-Type" : "application/json"])
                return stubResponse
        })

        let api = API.sharedInstance
        let endpoint = Endpoints.GetCurrentWeather
        let params = [
            "id" : 2643743
        ]
        let expectation = expectationWithDescription("Did get current weather")
        
        api.executeEndpoint(endpoint, withParameters: params) { response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            let object = response as? [String : AnyObject]
            XCTAssertNotNil(object)
            XCTAssertEqual(object?["name"] as? String, "London")
            XCTAssertEqual(object?["id"] as? Int, 2643743)
            XCTAssertEqual(object?["dt"] as? Int, 1463308797)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    
    func testGetWeatherForecastForCityWithID() {
        
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return request.URL!.absoluteString.containsString("http://api.openweathermap.org/data/2.5/forecast")
            }, withStubResponse: { _ in
                let testResponseFilePath = NSBundle(forClass: self.dynamicType).pathForResource("WeatherForecast", ofType: "json")!
                let stubResponse = OHHTTPStubsResponse(fileAtPath: testResponseFilePath, statusCode: 200, headers: ["Content-Type" : "application/json"])
                return stubResponse
        })

        
        
        let api = API.sharedInstance
        let endpoint = Endpoints.GetWeatherForecast
        let params = [
            "id" : 2643743
        ]
        
        let expectation = expectationWithDescription("Did get weather forecast")
        
        api.executeEndpoint(endpoint, withParameters: params) { response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            let object = response as? [String : AnyObject]
            XCTAssertNotNil(object)
            let city = object?["city"] as? [String : AnyObject]
            XCTAssertEqual(city?["name"] as? String, "London")
            XCTAssertEqual(city?["id"] as? Int, 2643743)
        
            let count = object?["cnt"] as? Int
            XCTAssertEqual(count, 40)
            
            let list = object?["list"] as? [[String : AnyObject]]
            XCTAssertNotNil(list)
            XCTAssertEqual(list?.count ?? 0, count)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    
}
