//
//  PlacesMapViewController.swift
//  Fencely
//
//  Created by Jordan Hudgens on 8/7/14.
//  Copyright (c) 2014 Jordan Hudgens. All rights reserved.
//

// TODO: Refactor data call and management into data source class
// Start iterating through data to display on screen

import UIKit
import MapKit
import CoreLocation

class PlacesMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: MKMapView
    var window: UIWindow?
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    
    @IBOutlet var buttonOne: UIButton!
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make this controller the delegate for the map view.
        self.mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
                
        println("Location is: \(location)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        initLocationManager();
        return true
    }

    
    // MARK: Map methods
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        var region: MKCoordinateRegion
        region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 1000, 1000)
        
        mapView.setRegion(region, animated:true)
    }
    
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
                locationManager.startUpdatingLocation()
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
            
            if (currentCentre == nil){
                currentCentre = coord
                self.queryGooglePlaces("cafe")
            }
            
            
            
            
            
            mapView.setCenterCoordinate(coord, animated: true)
            
            var latDelta:CLLocationDegrees = 0.025
            var longDelta:CLLocationDegrees = 0.025
            
            var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            
            var theRegion:MKCoordinateRegion = MKCoordinateRegionMake(coord, theSpan)
            
            mapView.setRegion(theRegion, animated: true)
            
            var initialAnnotation = MKPointAnnotation()
            
            initialAnnotation.coordinate = coord
            initialAnnotation.title = "Ricky Panzer's House"
            initialAnnotation.subtitle = "It is underground"
            
            
            mapView.addAnnotation(initialAnnotation)
        }
        
    }
    
    // Location Manager helper stuff
    func initLocationManager() {
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
    }
    
    // Location Manager Delegate stuff
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            if (seenError == false) {
                seenError = true
                print(error)
            }
        }
    }
    
    
    // MARK: API query
    
    var currentCentre : CLLocationCoordinate2D!
    var currenDist : Int!
    
    let kGOOGLE_API_KEY: String! = "AIzaSyAms5WELg7IHAGeU-X2AvqqRTjBjYG-tp0"
    let kBgQueue = "kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)"
    
    func queryGooglePlaces(googleType:String!) {
        currenDist = 1000
        let url = NSURL(string: ("https://maps.googleapis.com/maps/api/place/search/json?location=\(currentCentre.latitude),\(currentCentre.longitude)&radius=\(currenDist)&types=\(googleType)&sensor=true&key=\(kGOOGLE_API_KEY)"))
        
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
        println(jsonObject)
        if let places = jsonObject as? NSArray{
            println(places)
        }
    }
    
    // MARK: Actions
    @IBAction func buttonOnePressed(sender: UIButton) {
        buttonOne.titleLabel.text = buttonOne.titleLabel.text.lowercaseString
        
    }
    
}

