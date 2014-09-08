//
//  LocationManager.swift
//  Fencely
//
//  Created by Jordan Hudgens on 9/8/14.
//  Copyright (c) 2014 Jordan Hudgens. All rights reserved.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var manager: CLLocationManager = CLLocationManager()
    
    var initialized : Bool = false
    
    class var sharedInstance : LocationManager {
    struct Static {
        static let instance : LocationManager = LocationManager()
        
        }
        
        if (!Static.instance.initialized){
            Static.instance.initLocationManager()
            Static.instance.initialized = true
        }
        return Static.instance
    }
    

    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var currentCentre : CLLocationCoordinate2D!
    
    // MARK: Location methods
    var location: CLLocation!
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var shouldIAllow = false
            
            switch status {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Restricted Access to location"
            case CLAuthorizationStatus.Denied:
                locationStatus = "User denied access to location"
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Status not determined"
            default:
                locationStatus = "Allowed to location Access"
                shouldIAllow = true
            }
            NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
            if (shouldIAllow == true) {
                NSLog("Location to Allowed")
                // Start location services
                manager.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(locationStatus)")
            }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            var locationArray = locations as NSArray
            var locationObj = locationArray.lastObject as CLLocation
            var coord = locationObj.coordinate
            
            println(coord.latitude)
            println(coord.longitude)
            
            var finder = PlacesDataSource.sharedInstance
            
            if (currentCentre == nil){
                currentCentre = coord
                finder.queryGooglePlaces("cafe")
            }
            
            
        }
        
    }
    
    func initLocationManager() {
        
        manager.delegate = self
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if ((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
            manager.requestAlwaysAuthorization()
        }
        
        manager.startUpdatingLocation()
        
    }
    
    var seenError : Bool = false

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        manager.stopUpdatingLocation()
        if ((error) != nil) {
            if (seenError == false) {
                seenError = true
                print(error)
            }
        }
    }
}
