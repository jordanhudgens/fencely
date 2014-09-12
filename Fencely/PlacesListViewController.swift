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
        var rowData: Place = PlacesDataSource.sharedInstance.places[indexPath.row] as Place
        
        var spacelessString : NSString = rowData.address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        var mapUrl : NSString = "http://maps.apple.com/maps?daddr=\(spacelessString)"
        
        var url : NSURL = NSURL(string: mapUrl)
        
        UIApplication.sharedApplication().openURL(url)
        
    }
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    var listOfTypes : NSArray = ["accounting", "airport", "amusement_park", "aquarium", "art_gallery", "atm", "bakery", "bank", "bar", "beauty_salon", "bicycle_store", "book_store", "bowling_alley", "bus_station", "cafe", "campground", "car_dealer", "car_rental", "car_repair", "car_wash", "casino", "cemetery", "church", "city_hall", "clothing_store", "convenience_store", "courthouse", "dentist", "department_store", "doctor", "electrician", "electronics_store", "moving_company", "museum", "night_club", "painter", "park", "parking", "pet_store", "pharmacy", "physiotherapist", "place_of_worship", "plumber", "police", "post_office", "real_estate_agency", "restaurant", "roofing_contractor", "rv_park", "school", "shoe_store", "shopping_mall", "spa", "stadium", "storage", "store", "subway_station", "synagogue", "taxi_stand", "train_station", "travel_agency", "university", "veterinary_care", "zoo", "embassy", "establishment", "finance", "fire_station", "florist", "food", "funeral_home", "furniture_store", "gas_station", "general_contractor", "grocery_or_supermarket", "gym", "hair_care", "hardware_store", "health", "home_goods_store", "hospital", "insurance_agency", "jewelry_store", "laundry", "lawyer", "library", "liquor_store", "local_government_office", "locksmith", "lodging", "meal_delivery", "meal_takeaway", "movie_theater", "movie_rental"]
    
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


