//
//  DataHandler.swift
//  NearByCustomers
//
//  Created by Mac on 12/13/15.
//  Copyright © 2015 SoftwareEngineers. All rights reserved.
//

import Foundation
import CoreLocation

class DataHandler {
    
    internal static let sharedInstance = DataHandler()
    internal var dataSource = [Customer]()
    
    
    private init() {}
    
     //MARK: Custom Methods
    
    func fetchDataFromFile(){
        
        let pathOfFile: NSURL? = copyTextFileInDocumentDirectory()
//        print("\(pathOfFile)")
        
        if (pathOfFile != nil) {
            let resultString:String = readTextFile()
            parseStringAndPopulateDataSource(resultString)
        }
    }
    
    func copyTextFileInDocumentDirectory() -> NSURL? {
        
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        // If array of path is empty the document folder not found
        guard urls.count == 0 else {
            let finalDatabaseURL = urls.first!.URLByAppendingPathComponent("gistfile1.txt")
            // Check if file reachable, and if reachable just return path
            guard finalDatabaseURL.checkResourceIsReachableAndReturnError(nil) else {
                // Check if file exists in bundle folder
                if let bundleURL = NSBundle.mainBundle().URLForResource("gistfile1", withExtension: "txt") {
                    // if exists we will copy it
                    do {
                        try fileManager.copyItemAtURL(bundleURL, toURL: finalDatabaseURL)
                    } catch _ {
                        print("File copy failed!")
                    }
                } else {
                    print("File does not exist in Bundle")
                    return nil
                }
                return finalDatabaseURL
            }
            return finalDatabaseURL
        }
        return nil
    }
    
    
    func readTextFile()-> String {
        
        let file = "gistfile1.txt" //this is the file. we will write to and read from it
        var text2 = ""
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file);
            
            //reading from file
            do {
                text2 = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            }
            catch {
                print("Couldn't read the text file")
            }
        }
        return text2
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Couldnt serialize the JSON Object.")
            }
        }
        return nil
    }
    
    func parseStringAndPopulateDataSource (dataString: String) {
        // tokenizing the String separated by \n
        let array:[String] = dataString.componentsSeparatedByString("\n")
        
        for tempString in array {
//            print("The JSON String here is: \(tempString) finish.")
            
            let tempDict:[String:AnyObject]? = convertStringToDictionary(tempString)
            if((tempDict) != nil){
                
                let nameString:String = tempDict!["name"] as! String
                let userID: Int = tempDict!["user_id"] as! Int
                let longitude: Double = (tempDict!["longitude"]?.doubleValue)!
                let latitude: Double = (tempDict!["latitude"]?.doubleValue)!
                
                let coords:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let customerObj:Customer = Customer(name:nameString , id:userID , long:longitude , lat:latitude, coords:coords)
                dataSource.append(customerObj)
            }
        }
        dataSource.sortInPlace { (customer1:Customer, customer2:Customer) -> Bool in
            customer1.id < customer2.id
        }
    }
    
    
    
    
}