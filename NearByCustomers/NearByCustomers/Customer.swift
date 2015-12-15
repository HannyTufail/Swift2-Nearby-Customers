//
//  Customer.swift
//  NearByCustomers
//
//  Created by Mac on 12/12/15.
//  Copyright © 2015 SoftwareEngineers. All rights reserved.
//

import Foundation
import CoreLocation

class Customer {
    
    var name : String
    var id: Int
    var longitude: Double
    var latitude: Double
    var coordinate: CLLocationCoordinate2D
    
    
    init(name:String, id: Int, long: Double, lat: Double, coords:CLLocationCoordinate2D){
        self.name = name
        self.id = id
        longitude = long
        latitude = lat
        coordinate = coords
    }
}