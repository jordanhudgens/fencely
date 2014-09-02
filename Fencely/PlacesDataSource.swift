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
    
    let kGOOGLE_API_KEY: String! = "AIzaSyAms5WELg7IHAGeU-X2AvqqRTjBjYG-tp0"
    let kBgQueue = "kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)"
    
    func queryGooglePlaces(googleType:String!, currentCentre : CLLocationCoordinate2D!) {
        
        let manager = AFHTTPRequestOperationManager()

        var parameters = ["types": googleType,
                            "location": "\(currentCentre.latitude),\(currentCentre.longitude)",
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
    }
    
    // MARK: KVO methods
    var places : NSMutableArray!
    
    func countOfPlaces() -> Int {
        return self.places.count
    }
    
    func objectInPlacesAtIndex(index:Int) -> AnyObject {
        return self.places.objectAtIndex(index)
    }
    
    func placesAtIndexes(indexes: NSIndexSet) -> NSArray {
        return self.places.objectsAtIndexes(indexes)
    }
    
    func insertObjectinPlacesAtIndex(object: PlacesDataSource, index: Int) {
        places.insertObject(object, atIndex: index)
    }
    
    func removeObjectFromPlacesAtIndex(index: Int) {
        places.removeObjectAtIndex(index)
    }
    
    func replaceObjectInPlacesAtIndexWithObject(index: Int, object: AnyObject) {
        places.replaceObjectAtIndex(index, withObject: object)
    }
    
    func deletePlace(place: PlacesDataSource) {
        var mutableArrayWithKVO = self.mutableArrayValueForKey("places")
        mutableArrayWithKVO.removeObject(place)
    }

}
