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
    
    var listOfTypes : NSMutableArray = []
    
    
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
        self.tabBarItem.image = UIImage(named: "f-search-reg.png").imageScaledToFitSize(CGSizeMake(35, 35))
        
        var pmvc : PlacesMapViewController = self.tabBarController?.viewControllers![1] as PlacesMapViewController
        pmvc.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "f-map-reg.png").imageScaledToFitSize(CGSizeMake(35,35)).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: "f-map-reg.png").imageScaledToFitSize(CGSizeMake(35, 35)))
    }
    
    func venuesUpdated(sender : AnyObject) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Table delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !self.isFiltered {
            println("number of rows \(PlacesDataSource.sharedInstance.places.count)")

            return PlacesDataSource.sharedInstance.places.count
            
        } else {
            
            return self.filteredResults.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        if !self.isFiltered {
            var rowData: Place = PlacesDataSource.sharedInstance.places[indexPath.row] as Place
            
            
            cell.textLabel?.text = rowData.name as String
            cell.detailTextLabel?.text = rowData.address as String
            cell.detailTextLabel?.textColor = UIColor.brownColor()
        } else {
            var genre: String = self.filteredResults[indexPath.row] as String
            
            cell.textLabel?.text = genre as String
            cell.detailTextLabel?.text = "" as String
            cell.detailTextLabel?.textColor = UIColor.brownColor()
        }
        
        

        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if (listOfTypes.count > 0) {
            self.searchBar.text = ""

            if (self.isFiltered) {
                PlacesDataSource.sharedInstance.queryGooglePlaces(filteredResults[indexPath.row] as String)
            } else {
                PlacesDataSource.sharedInstance.queryGooglePlaces(listOfTypes[indexPath.row] as String)
            }
            
            listOfTypes.removeAllObjects()
            isFiltered = false
            self.searchBar.resignFirstResponder()
            self.tableView.reloadData()
        } else {
            
            self.searchBar.resignFirstResponder()
            var rowData: Place = PlacesDataSource.sharedInstance.places[indexPath.row] as Place
            
            var spacelessString : NSString = rowData.address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            var mapUrl : NSString = "http://maps.apple.com/maps?daddr=\(spacelessString)"
            
            var url : NSURL = NSURL(string: mapUrl)
            
            UIApplication.sharedApplication().openURL(url)
        }
        
        
    }
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    var filteredResults : NSMutableArray = NSMutableArray()
    var isFiltered : Bool = false
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        if (searchText.isEmpty)
        {
            filteredResults = listOfTypes.mutableCopy() as NSMutableArray
        } else {
            isFiltered = true
            filteredResults.removeAllObjects()
            for genre in listOfTypes {
                genre as String
                var typeRange : NSRange = genre.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                if typeRange.location != NSNotFound {
                    filteredResults.addObject(genre)
                }
            }
            
        }
        
        self.tableView.reloadData()
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        isFiltered = true
        
        listOfTypes.addObject("aquarium")
        listOfTypes.addObject("atm")
        listOfTypes.addObject("bakery")
        listOfTypes.addObject("bank")
        listOfTypes.addObject("bar")
        listOfTypes.addObject("cafe")
        listOfTypes.addObject("campground")
        listOfTypes.addObject("casino")
        listOfTypes.addObject("cemetery")
        listOfTypes.addObject("church")
        listOfTypes.addObject("courthouse")
        listOfTypes.addObject("dentist")
        listOfTypes.addObject("doctor")
        listOfTypes.addObject("electrician")
        listOfTypes.addObject("museum")
        listOfTypes.addObject("painter")
        listOfTypes.addObject("park")
        listOfTypes.addObject("parking")
        listOfTypes.addObject("pharmacy")
        listOfTypes.addObject("physiotherapist")
        listOfTypes.addObject("plumber")
        listOfTypes.addObject("police")
        listOfTypes.addObject("restaurant")
        listOfTypes.addObject("school")
        listOfTypes.addObject("spa")
        listOfTypes.addObject("stadium")
        listOfTypes.addObject("storage")
        listOfTypes.addObject("store")
        listOfTypes.addObject("synagogue")
        listOfTypes.addObject("university")
        listOfTypes.addObject("zoo")
        listOfTypes.addObject("embassy")
        listOfTypes.addObject("establishment")
        listOfTypes.addObject("finance")
        listOfTypes.addObject("florist")
        listOfTypes.addObject("food")
        listOfTypes.addObject("gym")
        listOfTypes.addObject("health")
        listOfTypes.addObject("hospital")
        listOfTypes.addObject("laundry")
        listOfTypes.addObject("lawyer")
        listOfTypes.addObject("library")
        listOfTypes.addObject("locksmith")
        listOfTypes.addObject("lodging")
        
        if (searchBar.text.isEmpty)
        {
            filteredResults = listOfTypes.mutableCopy() as NSMutableArray
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        isFiltered = false
        
        self.tableView.reloadData()
    }
    

    var queryFromButton: String?
    

    
}


