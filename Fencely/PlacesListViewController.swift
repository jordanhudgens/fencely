//
//  PlacesListViewController.swift
//  Fencely
//
//  Created by Jordan Hudgens on 8/7/14.
//  Copyright (c) 2014 Jordan Hudgens. All rights reserved.
//  appshocker.com/swift-programming-ios-101-part-4-mapkit-app-displaying-locations/

import UIKit
import MapKit

class PlacesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var tableData = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Explanation on notification center: http://stackoverflow.com/questions/24049020/nsnotificationcenter-addobserver-in-swift
        // Selector explanation: http://www.learnswift.io/blog/2014/6/11/using-nsnotificationcenter-in-swift
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "venuesUpdated:", name: "venues", object: nil)

        // Do any additional setup after loading the view, typically from a nib.
        //PlacesDataSource.sharedInstance.addObserver(self, forKeyPath:"places", options: nil, context: nil)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        LocationManager.sharedInstance
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        searchBar.delegate = self
    }
    
    func venuesUpdated(sender : AnyObject) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("number of rows \(PlacesDataSource.sharedInstance.places.count)")
        return PlacesDataSource.sharedInstance.places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var rowData: Place = PlacesDataSource.sharedInstance.places[indexPath.row] as Place
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = rowData.name as String
        cell.detailTextLabel?.text = rowData.address as String
        cell.detailTextLabel?.textColor = UIColor.brownColor()

        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var rowData: Place = PlacesDataSource.sharedInstance.places[indexPath.row] as Place
        
        var spacelessString : NSString = rowData.address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        var mapUrl : NSString = "http://maps.apple.com/maps?daddr=\(spacelessString)"
        
        var url : NSURL = NSURL(string: mapUrl)
        
        UIApplication.sharedApplication().openURL(url)
        
    }
    
    @IBOutlet var searchBar: UISearchBar!
    
    var listOfTypes : NSArray = ["Cafe", "Restaurant", "Bar"]
    var searchResults : NSArray?
    
    func filterContentForSearchText(searchText: NSString, scope: NSString) {
        var resultPredicate : NSPredicate
        
        searchResults = listOfTypes.filteredArrayUsingPredicate(resultPredicate.predicateFormat("name contains[\(searchText)]")) as NSArray
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (!searchText.isEmpty) {
            for genre in listOfTypes {
                println(genre)
            }
        }
    }
    

    var queryFromButton: String?
    
    @IBAction func cafeButtonPressed(sender: UIBarButtonItem) {
        PlacesDataSource.sharedInstance.queryGooglePlaces("cafe")
    }
    

    @IBAction func restaurantButtonPressed(sender: UIBarButtonItem) {
        PlacesDataSource.sharedInstance.queryGooglePlaces("restaurant")
    }
    
    @IBAction func barsButtonPressed(sender: UIBarButtonItem) {
        PlacesDataSource.sharedInstance.queryGooglePlaces("bar")
    }
    
    @IBAction func atmButtonPressed(sender: UIBarButtonItem) {
        PlacesDataSource.sharedInstance.queryGooglePlaces("atm")
    }
    
}


