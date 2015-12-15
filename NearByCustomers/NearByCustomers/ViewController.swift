//
//  ViewController.swift
//  NearByCustomers
//
//  Created by Mac on 12/12/15.
//  Copyright © 2015 SoftwareEngineers. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate {

    // MARK: Properties
    @IBOutlet var tableView: UITableView!
    var customerArray = [Customer]()
    let locationManager = CLLocationManager()
    var currentLocationCoords =   CLLocationCoordinate2D()
    var currentLocation =   CLLocation()
   
    // MARK: View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filterButton = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "filterTapped:")
        let showAllButton = UIBarButtonItem(title: "All", style: .Plain, target: self, action: "showAllTapped:")
        navigationItem.rightBarButtonItems = [filterButton, showAllButton]
        
        DataHandler.sharedInstance.fetchDataFromFile()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {

        let tempArray = DataHandler.sharedInstance.dataSource
        customerArray.appendContentsOf(tempArray)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Custom Methods
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    func getBearingBetweenTwoPoints(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude)
        let lon2 = degreesToRadians(point2.coordinate.longitude)
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var radiansBearing = atan2(y, x)
        
        if(radiansBearing < 0.0){
            radiansBearing += 2*M_PI;
        }
        
        return radiansToDegrees(radiansBearing)
    }
    
    func filterTapped(sender:AnyObject) {
        // Fetch Current Location
        // Compare the Current Long lat with the Long Lat in Array
        // Calculate the distance
        
        if (CLLocationCoordinate2DIsValid(currentLocationCoords)){
            
            var nearByCustomersArray = [Customer]()
            
            for customerItem in customerArray {
                let customerLocationCoords:CLLocationCoordinate2D = customerItem.coordinate
                let customerLocation = CLLocation(latitude: customerLocationCoords.latitude, longitude: customerLocationCoords.longitude)

                // For testing
//                let latitude:Double = 33.718151
//                let longitude:Double = 73.060547
//                print("Longitude: \(longitude) and Latitude: \(latitude)")
//                currentLocationCoords = CLLocationCoordinate2D(latitude: latitude, longitude:longitude)
//                currentLocation = CLLocation(latitude: latitude, longitude:longitude)
                
                let distanceBetween:Double = getBearingBetweenTwoPoints(currentLocation, point2: customerLocation)
                print("\(distanceBetween)")
                if(distanceBetween>100.0){
                    print("Distance is greater")
                }
                else {
                    print("Invite this Customer")
                    nearByCustomersArray.append(customerItem)
                }
            }
            customerArray.removeAll()
            customerArray.appendContentsOf(nearByCustomersArray)
        }
        tableView.reloadData()
    }
    func showAllTapped(sender:AnyObject)
    {
        customerArray.removeAll()
        let tempArray = DataHandler.sharedInstance.dataSource
        customerArray.appendContentsOf(tempArray)
        tableView.reloadData()
    }
    
    // MARK: TableView Delegate Methods
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Customers"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath:indexPath)
        
        let customerItem:Customer = customerArray[indexPath.row]
        
        let userIdLabel = cell.viewWithTag(1) as! UILabel
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let longLabel = cell.viewWithTag(3) as! UILabel
        let latLabel = cell.viewWithTag(4) as! UILabel
        
        userIdLabel.text = String.localizedStringWithFormat("%i", customerItem.id)
        nameLabel.text = String.localizedStringWithFormat("%@", customerItem.name)
        longLabel.text = String.localizedStringWithFormat("Long: %f", customerItem.longitude)
        latLabel.text = String.localizedStringWithFormat("Lat: %f", customerItem.latitude)
        
        return cell
    }
    
    // MARK: Location Manager Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: CLLocation = locations[locations.count - 1]
        
        let latitude = latestLocation.coordinate.latitude
        let longitude = latestLocation.coordinate.longitude
        print("Longitude: \(longitude) and Latitude: \(latitude)")
        
        currentLocationCoords = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
        currentLocation = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
}

