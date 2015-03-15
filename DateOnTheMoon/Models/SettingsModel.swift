//
//  SettingsModel.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 05/01/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import MapKit

let settings = SettingsModel()

class SettingsModel {
    var hasSeenWalkthrough = false
    var locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var currentCoordinate: CLLocationCoordinate2D?
    var userCoordinate: CLLocationCoordinate2D?
    var partnerCoordinate: CLLocationCoordinate2D?
    
    init() {
        //saveSettings()
        loadSettings()
    }
    
    func loadSettings() {
        if let hasSeenWalkthrough = NSUserDefaults.standardUserDefaults().objectForKey("HasSeenWalkthrough") as? Bool {
            self.hasSeenWalkthrough = hasSeenWalkthrough
        }
        
        let userLatitude = NSUserDefaults.standardUserDefaults().objectForKey("UserLatitude") as? Double
        let userLongitude = NSUserDefaults.standardUserDefaults().objectForKey("UserLongitude") as? Double
        if userLatitude != nil && userLongitude != nil {
            userCoordinate = CLLocationCoordinate2D(latitude: userLatitude!, longitude: userLongitude!)
        }
        
        let partnerLatitude = NSUserDefaults.standardUserDefaults().objectForKey("PartnerLatitude") as? Double
        let partnerLongitude = NSUserDefaults.standardUserDefaults().objectForKey("PartnerLongitude") as? Double
        if partnerLatitude != nil && partnerLongitude != nil {
            partnerCoordinate = CLLocationCoordinate2D(latitude: partnerLatitude!, longitude: partnerLongitude!)
        }
    }
    
    func saveSettings() {
        NSUserDefaults.standardUserDefaults().setObject(hasSeenWalkthrough, forKey: "HasSeenWalkthrough")
        
        if userCoordinate != nil {
            NSUserDefaults.standardUserDefaults().setObject(userCoordinate!.latitude, forKey: "UserLatitude")
            NSUserDefaults.standardUserDefaults().setObject(userCoordinate!.longitude, forKey: "UserLongitude")
        }
        if partnerCoordinate != nil {
            NSUserDefaults.standardUserDefaults().setObject(partnerCoordinate!.latitude, forKey: "PartnerLatitude")
            NSUserDefaults.standardUserDefaults().setObject(partnerCoordinate!.longitude, forKey: "PartnerLongitude")
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
