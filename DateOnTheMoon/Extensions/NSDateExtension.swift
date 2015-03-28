//
//  NSDateExtension.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 28/03/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit

extension NSDate {
  /* Get text description for date's time.
   * return {String}
   */
  var timeDescription: String {
    get {
      let posix = NSLocale(localeIdentifier: "en_US_POSIX")
      
      let timeFormatter = NSDateFormatter()
      timeFormatter.locale = posix
      timeFormatter.dateFormat = "hh:mm a"
      
      return timeFormatter.stringFromDate(self)
    }
  }
  
  /* Get text description for date's day.
  * return {String}
  */
  var dayDescription: String {
    get {
      let posix = NSLocale(localeIdentifier: "en_US_POSIX")
      
      let dayFormatter = NSDateFormatter()
      dayFormatter.locale = posix
      dayFormatter.dateFormat = "dd/MM/yy"
    
      return dayFormatter.stringFromDate(self)
    }
  }
}
