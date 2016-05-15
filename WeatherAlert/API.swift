//
//  API.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation

enum HTTPMethod : String {
    case GET = "GET"
}

enum APIFunction : String {
    case Weather = "weather"
}

typealias APIEndpoint = (method: HTTPMethod, function: APIFunction)
struct Endpoints {
    static let GetCurrentWeather: APIEndpoint = (.GET, .Weather)
}


class API {
    
    static let sharedInstance = API(appID: "87007d2e2b7d6d780bc634854fb2feba")
    private(set) var appID: String!
    var serverURL: NSURL {
        return NSURL(string: "http://api.openweathermap.org/data/2.5")!
    }
    
    typealias APIResponseBlock = ((response: AnyObject?, error: NSError?) -> ())

    /**
     Initialises API instance with given appID
     
     - parameter appID: App ID as provided by Open Wather
     
     - returns: Instance of API class
     */
    init(appID: String) {
        self.appID = appID
    }
    
    /**
     Creates an NSURLSession with default configuration and application/json content-type header
     
     - returns: NSURLSession should be used for OpenWather API
     */
    func getSession() -> NSURLSession {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.HTTPAdditionalHeaders = ["Content-Type" : "application/json"]
        let session = NSURLSession(configuration: sessionConfig)
        return session
    }
    
    
    // MARK: - Main handlers
    /**
     Handles url requests
     
     - parameter request:    URL Requst to process
     - parameter completion: returns a tuple of response and error optionals
     */
    func handleURLRequest(request: NSURLRequest, completion: APIResponseBlock) {
        let dataTask = getSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) in

            guard error == nil else  {
                completion(response: response, error: error)
                return
            }
            
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                dispatch_async(dispatch_get_main_queue(), {
                    completion(response: jsonData, error: nil)
                })
            } catch let err as NSError {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(response: response, error: err)
                })
            }
            
        })
        
        dataTask.resume()
    }
    
    /**
     Generates full url based on `APIEndpoint` object provided and optional parameters
     
     - warning: Currently handles onlt GET requests!
     
     - parameter endpoint: `APIEndpoint` to use
     - parameter params:   Parameters for a request
     
     - returns: URL Request object
     */
    func urlRequestForEndpoint(endpoint: APIEndpoint, params: [String : AnyObject]? = nil) -> NSMutableURLRequest? {
        let url = serverURL.URLByAppendingPathComponent(endpoint.function.rawValue)
        let comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        if params != nil {
            var queryItems: [NSURLQueryItem] = []
            for (key, value) in params! {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
            queryItems.append(NSURLQueryItem(name: "APPID", value: appID))
            comps?.queryItems = queryItems
        }
        
        if let newURL = comps?.URL {
            let request = NSMutableURLRequest(URL: newURL)
            request.HTTPMethod = endpoint.method.rawValue
            return request
        } else {
            return nil
        }
    }
    
    /**
     Runs `handleURLRequest` with given `APIEndpoint` and parameters
     
     - parameter endpoint:   `APIEndpoint` to use execute
     - parameter params:     Dictionary of parameters to use
     - parameter completion: returns a tuple of response and error optionals
     */
    func executeEndpoint(endpoint: APIEndpoint, withParameters params: [String : AnyObject]? = nil, completion: APIResponseBlock) {
        if let request = urlRequestForEndpoint(endpoint, params: params) {
            handleURLRequest(request, completion: completion)
        } else {
            completion(response: nil, error: NSError(domain: "API url request creation error domain", code: 400, userInfo: nil))
        }
        
    }
}

