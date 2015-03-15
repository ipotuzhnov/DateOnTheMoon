//
//  MomentsModel.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 05/01/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import Foundation
import UIKit

var momentsModel = MomentsModel()

class Moment {
  var start: NSDate
  var end: NSDate
  var angle: Double
  var duration: Double
  var phase: Double
  var weather = "cloudy"
  
  var phaseDescription: String {
    if phase < 0.45 {
      return "waxing"
    } else if phase < 0.55 {
      return "full"
    } else {
      return "waning"
    }
  }
  
  init(start: NSDate, end: NSDate, angle: Double, phase: Double) {
    self.start = start
    self.end = end
    self.angle = angle
    self.phase = phase
    // Calculate moment duration
    let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
    let diff = calendar?.components(.CalendarUnitMinute, fromDate: self.start, toDate: self.end, options: .MatchFirst)
    let inMinutes = diff?.minute
    let inHours = round(Double(inMinutes!) / 60.0 * 10.0) / 10.0
    self.duration = inHours
  }
  
  func asEllipticArc(frame: CGRect, offset: CGPoint, maxDuration maxDurationIn: Double, maxAngle maxAngleIn: Double) -> UIImage {
    let momentDuration = CGFloat(duration)
    let momentAngle = CGFloat(angle)
    let maxDuration = CGFloat(maxDurationIn)
    let maxAngle = CGFloat(maxAngleIn)
    let frameWidth = frame.width - 2 * offset.x
    let frameHeight = frame.height - offset.y
    
    let n = frameHeight * momentAngle / maxAngle
    let m: CGFloat = frameHeight * (180 - momentAngle) / maxAngle
    let b: CGFloat = n + m
    let k: CGFloat = frameWidth * momentDuration / maxDuration / 2
    let a: CGFloat = k * b / sqrt(b * b - m * m)
    
    let mx: CGFloat  = a / b
    let my: CGFloat  = 1.0
    var at = CGAffineTransformMakeScale(mx, my)
    
    let arc = UIBezierPath()
    
    // Find center
    var center = CGPoint()
    center.x = (offset.x + frameWidth / 2) / mx
    center.y = (offset.y + frameHeight - n + b) / my
    
    let alpha = atan2(k / mx, m / my)
    let startAngle: CGFloat = -CGFloat(M_PI)/2 - alpha
    let endAngle: CGFloat = -CGFloat(M_PI)/2 + alpha
    arc.addArcWithCenter(center, radius: b,
      startAngle: startAngle, endAngle: endAngle, clockwise: true)
    
    arc.applyTransform(at)
    
    // create a view to draw the path in
    let view = UIView(frame: frame)
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.mainScreen().scale)
    
    view.layer.renderInContext(UIGraphicsGetCurrentContext())
    
    let context = UIGraphicsGetCurrentContext()
    
    arc.stroke()
    
    // get an image of the graphics context
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image
  }
  
  func drawMoonIn(frame: CGRect, margin: CGFloat) -> UIImage {
    if phase > 1 {
      println("0 <= phase < 1")
      return UIImage()
    }
    
    let rotateAngle = CGFloat(M_PI/6)
    
    let atRot = CGAffineTransformMakeRotation(CGFloat(M_PI/6))
    
    var radius: CGFloat
    var center: CGPoint
    if frame.width < frame.height {
      radius = frame.width / 2 - margin
      center = CGPoint(x: frame.width / 2, y: frame.width / 2)
    } else {
      radius = frame.height / 2 - margin
      center = CGPoint(x: frame.height / 2, y: frame.height / 2)
    }
    
    // create a view to draw the path in
    let view = UIView(frame: frame)
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.mainScreen().scale)
    
    view.layer.renderInContext(UIGraphicsGetCurrentContext())
    
    let context = UIGraphicsGetCurrentContext()
    
    // Right side
    if phase < 1/2 { // Waxing
      drawMoonPartInContext(context, withColor: .grayColor(), rightSide: true, center: center, radius: radius, vertTransform: 1)
      
      if phase < 1/4 {
        let mx = CGFloat(1 - phase * 4)
        drawMoonPartInContext(context, withColor: .whiteColor(), rightSide: true, center: center, radius: radius, vertTransform: mx)
      }
    } else if phase < 3/4 { // Waning
      let mx = CGFloat(1 - (phase - 1/2) * 4)
      drawMoonPartInContext(context, withColor: .grayColor(), rightSide: true, center: center, radius: radius, vertTransform: mx)
    }
    
    // Left side
    if phase > 1/2 { // Waning
      drawMoonPartInContext(context, withColor: .grayColor(), rightSide: false, center: center, radius: radius, vertTransform: 1)
      
      if phase > 3/4 {
        let mx = CGFloat((phase - 3/4) * 4)
        drawMoonPartInContext(context, withColor: .whiteColor(), rightSide: false, center: center, radius: radius, vertTransform: mx)
      }
      
    } else if phase > 1/4 { // Waxing
      let mx = CGFloat((phase - 1/4) * 4)
      drawMoonPartInContext(context, withColor: .grayColor(), rightSide: false, center: center, radius: radius, vertTransform: mx)
    }
    
    // get an image of the graphics context
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image
  }
  
  func drawMoonPartInContext(context: CGContext, withColor color: UIColor, rightSide: Bool, center centerIn: CGPoint, radius: CGFloat, vertTransform mx: CGFloat) {
    let center = CGPoint(x: centerIn.x / mx, y: centerIn.y)
    var at = CGAffineTransformMakeScale (mx, 1)
    let path = UIBezierPath()
    var startAngle: CGFloat
    var endAngle: CGFloat
    if rightSide {
      startAngle = -CGFloat(M_PI/2)
      endAngle = CGFloat(M_PI/2)
    } else {
      startAngle = CGFloat(M_PI/2)
      endAngle = -CGFloat(M_PI/2)
    }
    path.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    path.applyTransform(at)
    CGContextSetFillColorWithColor(context, color.CGColor)
    path.fill()
  }
  
}

class MomentsModel {
  var moments = [Moment]()
  var maxAngle = 0.0
  var maxDuration = 0.0
  // Moment curve size
  var width  = 300.0
  var height = 40.0
  // Font sizes
  var timeFontSize = 14.0
  var dayFontSize  = 12.0
  var infoFontSize = 12.0
  // Time zone independent locale
  let posix: NSLocale
  // "dd/MM/yy"
  let dayFormatter: NSDateFormatter
  // "hh:mm a"
  let timeFormatter: NSDateFormatter
  // "dd/MM/yy hh:mm a"
  let formatter: NSDateFormatter
  init() {
    posix = NSLocale(localeIdentifier: "en_US_POSIX")
    
    dayFormatter = NSDateFormatter()
    dayFormatter.locale = posix
    dayFormatter.dateFormat = "dd/MM/yy"
    
    timeFormatter = NSDateFormatter()
    timeFormatter.locale = posix
    timeFormatter.dateFormat = "hh:mm a"
    
    formatter = NSDateFormatter()
    formatter.locale = posix
    formatter.dateFormat = "dd/MM/yy hh:mm a"
  }
  
  func addMoment(moment: Moment) {
    moments.append(moment)
    if (moment.angle > maxAngle) {
      maxAngle = moment.angle
    }
    if (moment.duration > maxDuration) {
      maxDuration = moment.duration
    }
  }
  
  func getStartingTime(index: Int) -> String {
    return timeFormatter.stringFromDate(moments[index].start)
  }
  
  func getStartingDay(index: Int) -> String {
    return dayFormatter.stringFromDate(moments[index].start)
  }
  
  func getEndingTime(index: Int) -> String {
    return timeFormatter.stringFromDate(moments[index].end)
  }
  
  func getEndingDay(index: Int) -> String {
    return dayFormatter.stringFromDate(moments[index].end)
  }
  
  func getMomentDuration(index: Int) -> Double {
    return moments[index].duration
  }
  
  func getMomentAngle(index: Int) -> Double {
    return moments[index].angle
  }
  
  func setTestMoments() {
    var start: NSDate?
    var end: NSDate?
    var angle: Double
    var phase: Double
    var moment: Moment
    start = formatter.dateFromString("11/10/14 10:34 PM")
    end   = formatter.dateFromString("12/10/14 03:58 AM")
    angle = 45.0
    phase = 1/8
    moment = Moment(start: start!, end: end!, angle: angle, phase: phase)
    self.addMoment(moment)
    start = formatter.dateFromString("25/03/14 01:27 PM")
    end   = formatter.dateFromString("25/03/14 09:27 PM")
    angle = 15.0
    phase = 1/2
    moment = Moment(start: start!, end: end!, angle: angle, phase: phase)
    self.addMoment(moment)
    start = formatter.dateFromString("23/06/14 10:13 PM")
    end   = formatter.dateFromString("24/06/14 01:25 AM")
    angle = 25.0
    phase = 11/16
    moment = Moment(start: start!, end: end!, angle: angle, phase: phase)
    self.addMoment(moment)
    start = formatter.dateFromString("18/11/14 09:21 PM")
    end   = formatter.dateFromString("19/11/14 02:21 AM")
    angle = 25.0
    phase = 1/16
    moment = Moment(start: start!, end: end!, angle: angle, phase: phase)
    self.addMoment(moment)
    start = formatter.dateFromString("11/10/14 11:30 PM")
    end   = formatter.dateFromString("12/10/14 04:55 AM")
    angle = 45.0
    phase = 7/16
    moment = Moment(start: start!, end: end!, angle: angle, phase: phase)
    self.addMoment(moment)
  }
}
