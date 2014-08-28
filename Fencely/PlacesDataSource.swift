//
//  PlacesDataSource.swift
//  Fencely
//
//  Created by Jordan Hudgens on 8/27/14.
//  Copyright (c) 2014 Jordan Hudgens. All rights reserved.
//

import Foundation
import CoreLocation

class PlacesDataSource: NSObject {
    
    // MARK: API query
    
    var currenDist : Int!
    
    let kGOOGLE_API_KEY: String! = "AIzaSyAms5WELg7IHAGeU-X2AvqqRTjBjYG-tp0"
    let kBgQueue = "kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)"
    
    func queryGooglePlaces(googleType:String!, currentCentre : CLLocationCoordinate2D!) {
        currenDist = 5000
        let url = NSURL(string: ("https://maps.googleapis.com/maps/api/place/search/json?types=\(googleType)&location=\(currentCentre.latitude),\(currentCentre.longitude)&rankby=distance&sensor=true&key=\(kGOOGLE_API_KEY)"))
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var err: NSError?
            var data: NSData = NSData.dataWithContentsOfURL(url,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
            
            dispatch_async(dispatch_get_main_queue(),{
                self.fetchedData(data)
            });
        }
        
    }
    
    func fetchedData(responseData:NSData) {
        let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers, error: nil)
//        println(jsonObject)
        if let places = jsonObject as? NSArray{
            println(places)
        }
    }

}
