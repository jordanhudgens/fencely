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
    
    var performQuery = PlacesDataSource()
    
    var tableData = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        println("number of rows \(tableData.count)")
        return tableData.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
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
                performQuery.queryGooglePlaces("cafe", currentCentre: currentCentre)
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
    
    
    // MARK: KVO methods go here
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if (object == PlacesDataSource.sharedInstance && keyPath == isEqual("places")) {
            var kindOfChange: Int = change[NSKeyValueChangeKindKey.integerValue]
            
            if (kindOfChange == NSKeyValueChangeSetting) {
                self.tableView.reloadData()
            } else if (kindOfChange == NSKeyValueChangeInsertion || kindOfChange == NSKeyValueChangeRemoval || kindOfChange == NSKeyValueChangeReplacement) {
                var indexSetOfChanges : NSIndexSet = change[NSKeyValueChangeIndexesKey]
                var indexPathsThatChanged : NSMutableArray?
                
                indexSetOfChanges.enumerateIndexesUsingBlock(idx: Int, stop: Bool) {
                    // Not sure of syntax on the line below
                    var newIndexPath : NSIndexPath = indexPathForRow(idx)inSection(0)
                    indexPathsThatChanged?.addObject(newIndexPath)
                    
                    self.tableView.beginUpdates()
                    
                    if (kindOfChange == NSKeyValueChangeInsertion) {
                        self.tableView.insertRowsAtIndexPaths(indexPathsThatChanged, withRowAnimation: UITableViewRowAnimationAutomatic)
                    } else if (kindOfChange == NSKeyValueChangeRemoval) {
                        self.tableView.deleteRowsAtIndexPaths(indexPathsThatChanged, withRowAnimation: UITableViewRowAnimationAutomatic)
                    } else if (kindOfChange == NSKeyValueChangeReplacement) {
                        self.tableView.reloadRowsAtIndexPaths(indexPathsThatChanged, withRowAnimation: UITableViewRowAnimationAutomatic)
                    }
                    
                    self.tableView.endUpdates()
                }
                
                if (PlacesDataSource.sharedInstance.places != nil && PlacesDataSource.sharedInstance.places.count > 0) {
                    self.refreshControl.endRefreshing
                }
            }
        }
    }
    
}


