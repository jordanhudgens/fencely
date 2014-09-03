//
//  PlacesListViewController.swift
//  Fencely
//
//  Created by Jordan Hudgens on 8/7/14.
//  Copyright (c) 2014 Jordan Hudgens. All rights reserved.
//  appshocker.com/swift-programming-ios-101-part-4-mapkit-app-displaying-locations/

import UIKit
import MapKit

class PlacesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var currentCentre : CLLocationCoordinate2D!
    
//    var performQuery = PlacesDataSource()
    
    var tableData = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Explanation on notification center: http://stackoverflow.com/questions/24049020/nsnotificationcenter-addobserver-in-swift
        // Selector explanation: http://www.learnswift.io/blog/2014/6/11/using-nsnotificationcenter-in-swift
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "venuesUpdated:", name: "venues", object: nil)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        PlacesDataSource.sharedInstance.addObserver(self, forKeyPath:"places", options: nil, context: nil)
//        [[BLCDataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if ((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        
    }
    
    func venuesUpdated(sender : AnyObject) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        println("number of rows \(PlacesDataSource.sharedInstance.places.count)")
        return PlacesDataSource.sharedInstance.places.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var rowData: NSDictionary = PlacesDataSource.sharedInstance.places[indexPath.row] as NSDictionary
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        cell.textLabel.text = rowData["name"] as String
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("You selected cell #\(indexPath.row)!")
    }
    
    // MARK: Location methods
    
    var window: UIWindow?
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    
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
                PlacesDataSource.sharedInstance.queryGooglePlaces("cafe", currentCentre: currentCentre)
            }
            
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

    
}


