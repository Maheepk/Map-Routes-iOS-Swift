//
//  DataProvider.swift
//  TaskProject
//
//  Created by Maheep Kaushal on 30/12/15.
//  Copyright © 2015 Maheep Kaushal. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import SwiftyJSON

class DataProvider {
    
    var task: NSURLSessionDataTask?
    var session: NSURLSession {
        return NSURLSession.sharedSession()
    }
    
    let googleUrl = "http://maps.googleapis.com/maps/api"
    let geoCodeMatrix = "geocode/json"
    let distanceMatrix = "directions/json"
    
    func getCoordinatesFromAddress(address: NSString, completion:((CLLocationCoordinate2D) -> Void))-> ()
    {
        let urlString = "\(googleUrl)/\(geoCodeMatrix)?sensor=false&address=\(address)"
        let escAddress = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet());
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let  url: NSURL = NSURL(string: escAddress!)!
        let  request: NSURLRequest = NSURLRequest(URL: url)
        
        task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var location = CLLocationCoordinate2D()
            
            if let aData = data {
                let json = JSON(data:aData, options:NSJSONReadingOptions.MutableContainers, error:nil)
                if let results = json["results"].arrayObject as? [[String : AnyObject]] {
                    
                    let  loc = results[0]["geometry"]!["location"]
                    
                    let  lat = (loc!!["lat"])!!.doubleValue
                    let  long  = (loc!!["lng"])!!.doubleValue
                    
                    location = CLLocationCoordinate2DMake(lat,long)
                    
                    completion (location)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(location)
            }
        })
        
        task?.resume()
    
    }
    
    func getStepFromCoordinates (start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, alternateRoutes: NSString,  mode: NSString, completion:((NSArray) -> Void))-> ()
    {
        let urlString = "\(googleUrl)/\(distanceMatrix)?origin=\(start.latitude),\(start.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&alternatives=\(alternateRoutes)&mode=\(mode)"
        let escAddress = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet());
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let  url: NSURL = NSURL(string: escAddress!)!
        let  request: NSURLRequest = NSURLRequest(URL: url)
        
        task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var routes = NSArray()

            if let aData = data {
                var json = JSON(data:aData, options:NSJSONReadingOptions.MutableContainers, error:nil)
                
                if json["status"] == "OK"{
                    
                    routes = json["routes"].arrayObject!
                    completion (routes)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion (routes)
            }
        })
        
        task?.resume()
    }

}

