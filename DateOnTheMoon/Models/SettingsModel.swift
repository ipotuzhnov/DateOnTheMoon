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
  var userTimezone: GooglePlaceTimezone?
  var userPlaceDescription: String?
  var partnerCoordinate: CLLocationCoordinate2D?
  var partnerTimezone: GooglePlaceTimezone?
  var partnerPlaceDescription: String?
  
  init() {
    //saveSettings()
    loadSettings()
  }
  
  func loadSettings() {
    if let hasSeenWalkthrough = NSUserDefaults.standardUserDefaults().objectForKey("HasSeenWalkthrough") as? Bool {
      self.hasSeenWalkthrough = hasSeenWalkthrough
    }
    
    /* Load user settings */
    
    let userLatitude = NSUserDefaults.standardUserDefaults().objectForKey("UserLatitude") as? Double
    let userLongitude = NSUserDefaults.standardUserDefaults().objectForKey("UserLongitude") as? Double
    if userLatitude != nil && userLongitude != nil {
      userCoordinate = CLLocationCoordinate2D(latitude: userLatitude!, longitude: userLongitude!)
    }
    
    let userDstOffset = NSUserDefaults.standardUserDefaults().objectForKey("UserDstOffset") as? Double
    let userRawOffset = NSUserDefaults.standardUserDefaults().objectForKey("UserRawOffset") as? Double
    userTimezone = GooglePlaceTimezone(dstOffset: userDstOffset, rawOffset: userRawOffset)
    
    userPlaceDescription = NSUserDefaults.standardUserDefaults().objectForKey("UserPlaceDescription") as? String
    
    /* Load partner's settings */
    
    let partnerLatitude = NSUserDefaults.standardUserDefaults().objectForKey("PartnerLatitude") as? Double
    let partnerLongitude = NSUserDefaults.standardUserDefaults().objectForKey("PartnerLongitude") as? Double
    if partnerLatitude != nil && partnerLongitude != nil {
      partnerCoordinate = CLLocationCoordinate2D(latitude: partnerLatitude!, longitude: partnerLongitude!)
    }
    
    let partnerDstOffset = NSUserDefaults.standardUserDefaults().objectForKey("PartnerDstOffset") as? Double
    let partnerRawOffset = NSUserDefaults.standardUserDefaults().objectForKey("PartnerRawOffset") as? Double
    partnerTimezone = GooglePlaceTimezone(dstOffset: partnerDstOffset, rawOffset: partnerRawOffset)
    
    partnerPlaceDescription = NSUserDefaults.standardUserDefaults().objectForKey("PartnerPlaceDescription") as? String
  }
  
  func saveSettings() {
    NSUserDefaults.standardUserDefaults().setObject(hasSeenWalkthrough, forKey: "HasSeenWalkthrough")
    
    /* Save user settings */
    
    if userCoordinate != nil {
      NSUserDefaults.standardUserDefaults().setObject(userCoordinate!.latitude, forKey: "UserLatitude")
      NSUserDefaults.standardUserDefaults().setObject(userCoordinate!.longitude, forKey: "UserLongitude")
    }
    
    if userTimezone != nil {
      NSUserDefaults.standardUserDefaults().setObject(userTimezone!.dstOffset, forKey: "UserDstOffset")
      NSUserDefaults.standardUserDefaults().setObject(userTimezone!.rawOffset, forKey: "UserRawOffset")
    }
    
    if userPlaceDescription != nil {
      NSUserDefaults.standardUserDefaults().setObject(userPlaceDescription!, forKey: "UserPlaceDescription")
    }
    
    /* Save partner's settings */
    
    if partnerCoordinate != nil {
      NSUserDefaults.standardUserDefaults().setObject(partnerCoordinate!.latitude, forKey: "PartnerLatitude")
      NSUserDefaults.standardUserDefaults().setObject(partnerCoordinate!.longitude, forKey: "PartnerLongitude")
    }
    
    if partnerTimezone != nil {
      NSUserDefaults.standardUserDefaults().setObject(partnerTimezone!.dstOffset, forKey: "PartnerDstOffset")
      NSUserDefaults.standardUserDefaults().setObject(partnerTimezone!.rawOffset, forKey: "PartnerRawOffset")
    }
    
    if partnerPlaceDescription != nil {
      NSUserDefaults.standardUserDefaults().setObject(partnerPlaceDescription!, forKey: "PartnerPlaceDescription")
    }
    
    NSUserDefaults.standardUserDefaults().synchronize()
  }
}
