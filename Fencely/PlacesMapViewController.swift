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
    
    @IBOutlet var buttonOne: UIButton!

    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Explanation on notification center: http://stackoverflow.com/questions/24049020/nsnotificationcenter-addobserver-in-swift
        // Selector explanation: http://www.learnswift.io/blog/2014/6/11/using-nsnotificationcenter-in-swift
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "venuesUpdated", name: "venues", object: nil)        
        
        // Do any additional setup after loading the view, typically from a nib.
        PlacesDataSource.sharedInstance.addObserver(self, forKeyPath:"places", options: nil, context: nil)
        
        //Make this controller the delegate for the map view.
        self.mapView.delegate = self
        
        mapView.showsUserLocation = true
        
        mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: false)
        
        self.venuesUpdated()
//        println("Location is: \(location)")
        
    }
    
    func venuesUpdated() {
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
        
        
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        LocationManager.sharedInstance.initLocationManager();
        return true
    }

    
    // MARK: Map methods
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        var region: MKCoordinateRegion
        region = MKCoordinateRegionMakeWithDistance(LocationManager.sharedInstance.manager.location.coordinate, 1000, 1000)
        
//        mapView.setRegion(region, animated:true)
    }
    

    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!){
        println("Hii")
        return
    }
    
    // MARK: MapView methods for placing location
    
    func userUpdatedLocation() {
    
        var latDelta:CLLocationDegrees = 0.05
        var longDelta:CLLocationDegrees = 0.05
    
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
    
        var theRegion:MKCoordinateRegion = MKCoordinateRegionMake(LocationManager.sharedInstance.currentCentre, theSpan)
    
        mapView.setRegion(theRegion, animated: true)
    
        var initialAnnotation = MKPointAnnotation()
    
        initialAnnotation.coordinate = LocationManager.sharedInstance.currentCentre
        initialAnnotation.title = "Current Location"
    
        mapView.addAnnotation(initialAnnotation)
    }
    
    

    
    // MARK: Actions
    @IBAction func buttonOnePressed(sender: UIButton) {
        buttonOne.titleLabel?.text = buttonOne.titleLabel?.text
        var finder = PlacesDataSource()
        
        if (LocationManager.sharedInstance.currentCentre != nil){
            finder.queryGooglePlaces(buttonOne.titleLabel?.text)
        } else {
            let alert = UIAlertView()
            alert.title = "Location Error"
            alert.message = "We couldn't find your location"
            alert.addButtonWithTitle("Close")
            alert.show()
        }
    }
    
}

