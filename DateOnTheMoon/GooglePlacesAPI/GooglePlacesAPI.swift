//
//  GooglePlacesAutocomplete.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 28/02/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import Foundation

class GooglePlace {
  var id: String?
  var locality: String?
  var state: String?
  var country: String?
  
  init(id: String?, locality: String?, state: String?, country: String?) {
    self.id = id
    self.locality = locality
    self.state = state
    self.country = country
  }
  
  func getCoordinate(completionHandler: (coordinate: GooglePlaceCoordinate?, error: String?) -> ()) {
    if id == nil { return completionHandler(coordinate: nil, error: "place.id == nil") }
    
    GooglePlacesAPI.shared.getPlaceCoordinate(id!, completionHandler: completionHandler)
  }
  
  var description: String {
    get {
      var description = locality == nil ? "" : "\(locality!)"
      description += state == nil ? "" : ", \(state!)"
      description += country == nil ? "" : ", \(country!)"
      return description
    }
  }
}

class GooglePlaceCoordinate {
  var latitude: Double?
  var longitude: Double?
  
  init(latitude: Double?, longitude: Double?) {
    self.latitude = latitude
    self.longitude = longitude
  }
  
  func getTimezone(completionHandler: (timezone: GooglePlaceTimezone?, error: String?) -> ()) {
    GooglePlacesAPI.shared.getTimezone(latitude, longitude: longitude, completionHandler: completionHandler)
  }
}

class GooglePlaceTimezone {
  var dstOffset: Double?
  var rawOffset: Double?
  
  init(dstOffset: Double?, rawOffset: Double?) {
    self.dstOffset = dstOffset
    self.rawOffset = rawOffset
  }
  
  var description: String {
    get {
      var description = ""
      if rawOffset == nil { return description }
      
      description += "UTC"
      if rawOffset > 0 { description += "+" }
      return description + "\(Int(rawOffset! / 60 / 60))"
    }
  }
}

/*  GooglePlaceCache is a singleton class that keeps cache for user requests.
*
*  @property {Dictionary} places Dictionary of user requests.
*  @property {Dictionary} detailes Dictionary of place's details.
*/
class GooglePlacesCache {
  var places = [String: [GooglePlace]]()
  var coordinates = [String: GooglePlaceCoordinate]()
  
  class var shared : GooglePlacesCache {
    
    struct Static {
      static let instance : GooglePlacesCache = GooglePlacesCache()
    }
    
    return Static.instance
  }
}

class GooglePlacesAPI: NSObject, NSURLConnectionDelegate {
  let session = NSURLSession.sharedSession()
  
  var apiKey = ""
  let autocompleteApiURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
  let detailsApiURL = "https://maps.googleapis.com/maps/api/place/details/json"
  let timezoneApiURL = "https://maps.googleapis.com/maps/api/timezone/json"
  
  class var shared: GooglePlacesAPI {
    
    struct Static {
      static let instance : GooglePlacesAPI = GooglePlacesAPI()
    }
    
    return Static.instance
  }
  
  override init() {
    super.init()
    
    let apiKeyPath = NSBundle.mainBundle().pathForResource("GooglePlacesAPI", ofType: "plist")
    if apiKeyPath == nil { return }
    
    let apiKeyDictionary = NSDictionary(contentsOfFile: apiKeyPath!)
    if let apiKey = apiKeyDictionary?.objectForKey("GooglePlacesApiKey") as? String {
      self.apiKey = apiKey
    }
  }
  
  func getPredictions(query: String, completionHandler: (places: [GooglePlace], error: String?) -> ()) {
    if var places = GooglePlacesCache.shared.places[query] {
      places.append(GooglePlace(id: nil, locality: "from cache", state: nil, country: nil))
      return completionHandler(places: places, error: nil)
    }
    
    let urlPath = autocompleteApiURL +
      "?input=" + query +
      "&types=" + "(cities)" +
      "&key="   + apiKey
    
    let url = NSURL(string: urlPath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
    
    if url == nil { return completionHandler(places: [], error: "url == nil") }
    
    let task = session.dataTaskWithURL(url!) {
      (data, response, error) in
      let (places, error) = self.parsePredictionsJSON(data)
      GooglePlacesCache.shared.places[query] = places
      completionHandler(places: places, error: error)
    }
    
    task.resume()
  }
  
  func getPlaceCoordinate(id: String, completionHandler: (coordinate: GooglePlaceCoordinate?, error: String?) -> ()) {
    if let coordinate = GooglePlacesCache.shared.coordinates[id] {
      return completionHandler(coordinate: coordinate, error: nil)
    }
    
    let urlPath = detailsApiURL +
      "?placeid=" + id +
      "&key=" + apiKey
    
    let url = NSURL(string: urlPath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
    
    if url == nil { return completionHandler(coordinate: nil, error: "url == nil") }
    
    let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
      (data, response, error) in
      let (coordinate, error) = self.parsePlaceCoordinateJSON(data)
      GooglePlacesCache.shared.coordinates[id] = coordinate
      completionHandler(coordinate: coordinate, error: error)
    }
    
    task.resume()
  }
  
  func getTimezone(latitude: Double?, longitude: Double?, completionHandler: (timezone: GooglePlaceTimezone?, error: String?) -> ()) {
    if latitude == nil || longitude == nil { return completionHandler(timezone: nil, error: "Invalid coordinate.") }
    
    let location = "\(latitude!),\(longitude!)"
    let timestamp = "\(Int(NSDate().timeIntervalSince1970))"
    
    let urlPath = timezoneApiURL +
      "?location=" + location +
      "&timestamp=" + timestamp +
      "&key=" + apiKey
    
    let url = NSURL(string: urlPath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
    
    if url == nil { return completionHandler(timezone: nil, error: "url == nil") }
    
    let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
      (data, response, error) in
      let (timezone, error) = self.parsePlaceTimezoneJSON(data)
      completionHandler(timezone: timezone, error: error)
    }
    
    task.resume()
  }
  
  func parsePredictionsJSON(data: NSData) -> ([GooglePlace], String?) {
    var places = [GooglePlace]()
    var err: NSError?
    // throwing an error on the line below (can't figure out where the error message is)
    var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
    
    if err != nil { return (places, "Error: \(err)") }
    
    let status = jsonResult["status"] as? String
    let error = jsonResult["error_message"] as? String
    
    if error != nil { return (places, "Status: \(status). Error: \(error)") }
    
    let predictions = jsonResult["predictions"] as? NSArray
    for prediction in predictions as! [NSDictionary] {
      let terms = prediction["terms"] as? NSArray
      
      if terms?.count == 0 { return (places, "terms.count == 0") }
      
      let locality = (terms?[0] as? NSDictionary)?["value"] as? String
      var state: String?
      var country: String?
      if terms?.count == 2 {
        country = (terms?[1] as? NSDictionary)?["value"] as? String
      } else if terms?.count == 3 {
        state = (terms?[1] as? NSDictionary)?["value"] as? String
        country = (terms?[2] as? NSDictionary)?["value"] as? String
      }
      let id = prediction["place_id"] as? String
      places.append(GooglePlace(id: id, locality: locality, state: state, country: country))
    }
    
    return (places, nil)
  }
  
  func parsePlaceCoordinateJSON(data: NSData) -> (GooglePlaceCoordinate?, String?) {
    var coordinate: GooglePlaceCoordinate?
    var err: NSError?
    var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
    
    if err != nil { return (coordinate, "Error: \(err)") }
    
    let status = jsonResult?["status"] as? String
    let error = jsonResult?["error_message"] as? String
    
    if error != nil { return (coordinate, "Status: \(status). Error: \(error)") }
    
    let result = jsonResult?["result"] as? NSDictionary
    let geometry = result?["geometry"] as? NSDictionary
    let location = geometry?["location"] as? NSDictionary
    
    let latitude = location?["lat"] as? Double
    let longitude = location?["lng"] as? Double
    coordinate = GooglePlaceCoordinate(latitude: latitude, longitude: longitude)
    
    return (coordinate, nil)
  }
  
  func parsePlaceTimezoneJSON(data: NSData) -> (GooglePlaceTimezone?, String?) {
    var timezone: GooglePlaceTimezone?
    var err: NSError?
    var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
    
    if err != nil { return (timezone, "Error: \(err)") }
    
    let status = jsonResult?["status"] as? String
    
    if status != "OK" { return (timezone, "Status: \(status).") }
    
    let dstOffset = jsonResult?["dstOffset"] as? Double
    let rawOffset = jsonResult?["rawOffset"] as? Double
    
    timezone = GooglePlaceTimezone(dstOffset: dstOffset, rawOffset: rawOffset)
    
    return (timezone, nil)
  }
  
}