//
//  UserMapView.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 05/01/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationView:
  UIViewController,
  MKMapViewDelegate,
  UITableViewDataSource, UITableViewDelegate,
  UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
  
  @IBOutlet weak var searchView: UIView!
  
  @IBAction func saveLocation() {
    coordinate = mapView?.centerCoordinate
    
    GooglePlacesAPI.shared.getTimezone(coordinate?.latitude, longitude: coordinate?.longitude) {
      (timezone, error) in
      if error != nil {
        dispatch_async(dispatch_get_main_queue()) {
          self.showAlert("GPA.getTimezone.ERROR", message: error!)
          return
        }
      }
      
      if timezone?.dstOffset != nil {
        dispatch_async(dispatch_get_main_queue()) {
          //self.showAlert("Timezone", message: timezone!.description)
          
          if self.locationIdentifier == "chooseUserLocation" {
            settings.userCoordinate = self.coordinate
            settings.userTimezone = timezone
          }
          
          if self.locationIdentifier == "choosePartnerLocation" {
            settings.partnerCoordinate = self.coordinate
            settings.partnerTimezone = timezone
          }
          
          settings.saveSettings()
          self.navigationController!.popViewControllerAnimated(true)
          return
        }
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          self.showAlert("Timezone", message: "Can't get descriprion")
          return
        }
      }
    }
  }
  
  var searchController: UISearchController!
  var searchResultsController: UITableViewController!
  var places = [GooglePlace]()
  
  var mapView: MKMapView?
  var pinView: UIImageView?
  
  var locationIdentifier = ""
  
  //let geocoder = CLGeocoder()
  //var searchResults = [MKPlacemark]()
  //var localSearch: MKLocalSearch?
  var coordinate: CLLocationCoordinate2D?
  var locationDescription: String?
  var geocoder: CLGeocoder?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    if locationIdentifier == "chooseUserLocation" {
      coordinate = settings.userCoordinate
    }
    
    if locationIdentifier == "choosePartnerLocation" {
      coordinate = settings.partnerCoordinate
    }
    
    if coordinate == nil {
      coordinate = settings.currentCoordinate
    }
    
    addSearchBar()
    searchController.searchBar.placeholder = "Enter city name or drag the map"
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /* UIViewController */
  override func viewDidLayoutSubviews() {
    addMapView(searchView)
    addPin(searchView)
  }
  
  /* Adds UISearchBar */
  func addSearchBar() {
    searchResultsController = UITableViewController()
    searchResultsController.tableView.dataSource = self
    searchResultsController.tableView.delegate = self
    
    searchController = UISearchController(searchResultsController: searchResultsController)
    searchController.searchResultsUpdater = self
    searchController.delegate = self
    searchController.searchBar.sizeToFit()
    searchController.searchBar.delegate = self
    
    searchView.addSubview(searchController.searchBar)
    
    definesPresentationContext = true
  }
  
  /* Adds MKMapView to the view.
  * @param {UIView} view The view to add map.
  */
  func addMapView(view: UIView) {
    let x: CGFloat = 0
    let y: CGFloat = searchController.searchBar.frame.height
    let width = view.frame.width
    let height = view.frame.height
    let mapViewFrame = CGRect(x: x, y: y, width: width, height: height)
    if mapView == nil {
      mapView = MKMapView(frame: mapViewFrame)
      searchView.addSubview(mapView!)
      showCoordinate(coordinate)
    } else {
      mapView!.frame = mapViewFrame
    }
  }
  
  /* Adds UIImage map_pin.png to the center of the view
  * @param {UIView} view The view to add pin
  */
  func addPin(view: UIView) {
    // 320 * 512
    let l = mapView!.center
    let width: CGFloat = 40
    let height: CGFloat = 64
    let x = (mapView!.frame.size.width - width) / 2
    let y = (mapView!.frame.size.height - height) / 2
    let pinViewFrame = CGRect(x: x, y: y, width: width, height: height)
    if pinView == nil {
      pinView = UIImageView(frame: pinViewFrame)
      let pinImage = UIImage(named: "map_pin.png")
      pinView!.image = pinImage
      view.addSubview(pinView!)
    } else {
      pinView!.frame = pinViewFrame
    }
  }
  
  /* Checks if given coordinate is valid and changes currently visible region.
  * @param {CLLocationCoordinate2D} coordinate The coordinate to be shown.
  * Returns a {Bool} for function success.
  */
  func showCoordinate(coordinate: CLLocationCoordinate2D?) {
    if coordinate == nil { return }
    
    let location = CLLocation(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
    if location.horizontalAccuracy < 0 { return }
    
    if !CLLocationCoordinate2DIsValid(coordinate!) { return }
    
    let span = MKCoordinateSpanMake(1, 1)
    let region = MKCoordinateRegion(center: coordinate!, span: span)
    mapView?.setRegion(region, animated: true)
  }
  
  /* Searches after delay if query is not changed.
  * @param {String} query Search query.
  * @param {Double} delay Delay in seconds.
  */
  func search(query: String, delay: Double) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      NSThread.sleepForTimeInterval(delay)
      
      if query != self.searchController.searchBar.text { return }
      
      GooglePlacesAPI.shared.getPredictions(query) {
        (places, error) in
        if error != nil {
          println(error)
          return
        }
        
        objc_sync_enter(self)
        if query == self.searchController.searchBar.text {
          self.places = places
        }
        objc_sync_exit(self)
        dispatch_async(dispatch_get_main_queue()) {
          self.searchResultsController.tableView.reloadData()
        }
      }
    })
  }
  
  /* UITableViewDelegate */
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    objc_sync_enter(self)
    let place = places[indexPath.row]
    objc_sync_exit(self)
    
    place.getCoordinate {
      (coordinate, error) in
      dispatch_async(dispatch_get_main_queue()) {
        var title = "Alert view!"
        var message: String = "Fetched coordinates!"
        if error != nil {
          title = "Error!"
          message = error!
        }
        let latitude = coordinate?.latitude
        let longitude = coordinate?.longitude
        if latitude != nil && longitude != nil {
          self.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
          self.showCoordinate(self.coordinate)
          return
        } else {
          title = "Error!"
          message = "Could not get coordinate."
        }
        self.showAlert(title, message: message)
      }
    }
    
    searchController.active = false
  }
  
  /* UITableViewDataSource */
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    objc_sync_enter(self)
    let count = self.places.count
    objc_sync_exit(self)
    return count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .Value1, reuseIdentifier: "searchResultCell")
    objc_sync_enter(self)
    let place = self.places[indexPath.row]
    objc_sync_exit(self)
    cell.textLabel?.text = place.description
    cell.selectionStyle = .None
    
    return cell
  }
  
  /* UISearchBarDelegate */
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  /* UISearchResultsUpdating */
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    let searchQuery = self.searchController.searchBar.text
    
    if count(searchQuery) == 0 {
      objc_sync_enter(self)
      self.places = []
      objc_sync_exit(self)
      searchResultsController.tableView.reloadData()
      return
    }
    
    search(searchQuery, delay: 0.3)
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
