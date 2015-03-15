//
//  SettingsView.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 05/01/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SettingsView: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    requestLocation()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func requestLocation() {
    let status = CLLocationManager.authorizationStatus()
    if status == .Restricted || status == .Denied {
      // Alert that location service is denied
      println("location service is denied")
      return
    }
    
    settings.locationManager.delegate = self
    settings.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    if status == .NotDetermined {
      settings.locationManager.requestAlwaysAuthorization()
    }
    settings.locationManager.startUpdatingLocation()
    
  }
  
  /* UITableViewDelegate */
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0:
        self.performSegueWithIdentifier("chooseUserLocation", sender: self)
      case 1:
        self.performSegueWithIdentifier("choosePartnerLocation", sender: self)
      default:
        return
      }
    default:
      return
    }
    //self.performSegueWithIdentifier("chooseUserLocation", sender: nil)
  }
  
  /* UITableViewDataSource */
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Locations"
    case 1:
      return "Add new setting"
    default:
      return ""
    }
  }
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var numberOfRows: Int
    switch section {
    case 0:
      numberOfRows = 2
    default:
      numberOfRows = 0
    }
    return numberOfRows
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell: UITableViewCell
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0:
        cell = UITableViewCell(style: .Value1, reuseIdentifier: "yourLocationCell")
        cell.textLabel?.text = "Your location"
        cell.accessoryType = .DisclosureIndicator
        cell.selectionStyle = .None
      case 1:
        cell = UITableViewCell(style: .Value1, reuseIdentifier: "partnerLocationCell")
        cell.textLabel?.text = "Partner's location"
        cell.accessoryType = .DisclosureIndicator
        cell.selectionStyle = .None
      default:
        cell = UITableViewCell()
      }
    default:
      cell = UITableViewCell()
    }
    return cell
  }
  
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let locationView = segue.destinationViewController as LocationView // TODO @ilia remove
    if let id = segue.identifier {
      locationView.locationIdentifier = id
      switch id {
      case "chooseUserLocation":
        return
        //self.nodeID
        
        //locationView.view.nodeID = self.nodeID; //--pass nodeID from ViewNodeViewController
        //translationQuizAssociateVC.contentID = self.contentID;
        //translationQuizAssociateVC.index = self.index;
        //translationQuizAssociateVC.content = self.content;
      default:
        return
      }
    }
    
    let y = 2
  }
  
  /* CCLocationManagerDelegate */
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    println("\(status.hashValue)")
    if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
      settings.locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    println(error)
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    println("did update locations")
    let currentLocations = locations as [CLLocation]
    if let location = locations.first as? CLLocation {
      //let currentCoordinate = settings.currentCoordinate
      //settings.currentCoordinate = location.coordinate
      let hasSameLatitude = settings.currentCoordinate?.latitude == location.coordinate.latitude
      let hasSameLongitude = settings.currentCoordinate?.longitude == location.coordinate.longitude
      if hasSameLatitude && hasSameLongitude {
        settings.locationManager.stopUpdatingLocation()
      }
      settings.currentCoordinate = location.coordinate
      
      /*
      settings.geocoder.reverseGeocodeLocation(location, completionHandler: {
      (placemarks, error) in
      if error != nil {
      println("reverse geodcode fail: \(error.localizedDescription)")
      }
      let pm = placemarks as [CLPlacemark]
      if let placemark = pm.first {
      println("\(placemark.locality), \(placemark.country)")
      }
      })
      */
    }
  }
  
}
