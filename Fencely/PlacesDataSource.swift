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
    
    class var sharedInstance : PlacesDataSource {
        struct Static {
            static let instance : PlacesDataSource = PlacesDataSource()
        }
        return Static.instance
    }
    
    // MARK: API call
    
    var currenDist : Int!
    var places: NSMutableArray = NSMutableArray()
    
    let kGOOGLE_API_KEY: String! = "AIzaSyAms5WELg7IHAGeU-X2AvqqRTjBjYG-tp0"
    let kBgQueue = "kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)"
    
    func queryGooglePlaces(googleType:String!) {
        
        let manager = AFHTTPRequestOperationManager()

        var parameters = ["types": googleType,
                            "location": "\(LocationManager.sharedInstance.currentCentre.latitude),\(LocationManager.sharedInstance.currentCentre.longitude)",
                            "rankby": "distance",
                            "sensor": "true",
                            "key":kGOOGLE_API_KEY]
        
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.GET("https://maps.googleapis.com/maps/api/place/search/json",
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                println("JSON: " + responseObject.description)
                self.fetchedData(responseObject as NSDictionary)
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
        })
    
    }
    
    func fetchedData(responseData:NSDictionary) {
        println(responseData)
        
        var placesArray : NSMutableArray = responseData["results"] as NSMutableArray
        
        places.removeAllObjects()
        
        for placeDictionary in placesArray {
            var place = Place()
            place.name = placeDictionary["name"] as String
            place.address = placeDictionary["vicinity"] as String
            place.latitude = ((placeDictionary["geometry"] as NSDictionary)["location"] as NSDictionary)["lat"] as CLLocationDegrees
            place.longitude = ((placeDictionary["geometry"] as NSDictionary)["location"] as NSDictionary)["lng"] as CLLocationDegrees
            places.addObject(place)
        }
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("venues", object: nil)
    }
 

}
