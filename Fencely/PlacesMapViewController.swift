//
//  PlacesMapViewController.swift
//  Fencely
//
//  Created by Jordan Hudgens on 8/7/14.
//  Copyright (c) 2014 Jordan Hudgens. All rights reserved.
//


import UIKit
import MapKit

class PlacesMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: MKMapView
    var window: UIWindow?
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var currentCentre : CLLocationCoordinate2D!
    
    @IBOutlet var buttonOne: UIButton!

    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Explanation on notification center: http://stackoverflow.com/questions/24049020/nsnotificationcenter-addobserver-in-swift
        // Selector explanation: http://www.learnswift.io/blog/2014/6/11/using-nsnotificationcenter-in-swift
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "venuesUpdated:", name: "venues", object: nil)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        PlacesDataSource.sharedInstance.addObserver(self, forKeyPath:"places", options: nil, context: nil)
        
        //Make this controller the delegate for the map view.
        self.mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if ((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
                
        println("Location is: \(location)")
        
    }
    
    func venuesUpdated(sender : NSMutableDictionary) {
        for place in PlacesDataSource.sharedInstance.places {
            
            var tempPlace : Place = place as Place
            var latitude = tempPlace.latitude
            var longitude = tempPlace.longitude
            var name = tempPlace.name
            
            var address = tempPlace.address
            var myHome:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            
            var initialAnnotation = MKPointAnnotation()
            
            
            initialAnnotation.coordinate = myHome
            initialAnnotation.title = name
            initialAnnotation.subtitle = address
            
            
            mapView.addAnnotation(initialAnnotation)
        }
        
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

            var finder = PlacesDataSource()
            
            if (currentCentre == nil){
                currentCentre = coord
                finder.queryGooglePlaces("cafe", currentCentre: currentCentre)
            }
            
            mapView.setCenterCoordinate(coord, animated: true)
            
            var latDelta:CLLocationDegrees = 0.025
            var longDelta:CLLocationDegrees = 0.025
            
            var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            
            var theRegion:MKCoordinateRegion = MKCoordinateRegionMake(coord, theSpan)
            
            mapView.setRegion(theRegion, animated: true)
            
            var initialAnnotation = MKPointAnnotation()
            
            initialAnnotation.coordinate = coord
            initialAnnotation.title = "Current Location"
            
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
    
    

    
    // MARK: Actions
    @IBAction func buttonOnePressed(sender: UIButton) {
        buttonOne.titleLabel?.text = buttonOne.titleLabel?.text
        var finder = PlacesDataSource()
        
        if (currentCentre != nil){
            finder.queryGooglePlaces(buttonOne.titleLabel?.text, currentCentre: currentCentre)
        } else {
            let alert = UIAlertView()
            alert.title = "Location Error"
            alert.message = "We couldn't find your location"
            alert.addButtonWithTitle("Close")
            alert.show()
        }
    }
    
}

