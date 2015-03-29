//
//  DetailMomentView.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 14/03/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit

class DetailMomentView: UIViewController {
  @IBAction func shareMoment(sender: UIBarButtonItem) {
    let shareView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 400))
    addMomentDetails(shareView)
    UIGraphicsBeginImageContext(shareView.frame.size)
    let context = UIGraphicsGetCurrentContext()
    shareView.layer.renderInContext(context)
    let shareImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let objectsToShare = [shareImage]
    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      
    self.presentViewController(activityVC, animated: true, completion: nil)
  }
  
  
  var moment: Moment?
  var uMoment: Moment?
  var pMoment: Moment?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidLayoutSubviews() {
    addMomentDetails(view, topBarOffset: topLayoutGuide.length)
  }
  
  /* Add moment details to the given view.
   * @param {UIView} view Given view.
   * @param {CGFloat} topBarOffset Offset.
   */
  func addMomentDetails(view: UIView, topBarOffset: CGFloat = 0) {
    if moment == nil { return }
  
    let viewBounds = view.bounds
    
    println(viewBounds)
    
    let uTimeOffset = settings.userTimezone?.rawOffset
    let pTimeOffset = settings.partnerTimezone?.rawOffset
    
    if uTimeOffset == nil || pTimeOffset == nil { return }
    
    let margin: CGFloat = 10
    
    // Add moon image
    
    let diameter: CGFloat = 80
    let moonFrame = CGRect(x: 0, y: topBarOffset, width: diameter, height: diameter)
    let moonMargin: CGFloat = 0
    let moonImage = moment!.drawMoonIn(moonFrame, margin: moonMargin, color: .whiteColor())
    let moonViewFrame = CGRect(x: 10, y: topBarOffset + 10, width: diameter, height: diameter)
    let moonView = UIImageView(frame: moonViewFrame)
    moonView.image = moonImage
    moonView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI/10), 0, 0, 1)
    view.addSubview(moonView)
    
    // Add moon phase label
    
    let phaseLabelX: CGFloat = margin + diameter + margin
    let phaseLabelY: CGFloat = topBarOffset + margin
    let phaseLabelW: CGFloat = viewBounds.width - phaseLabelX - margin
    let phaseLabelH: CGFloat = 20
    let phaseLabelFrame = CGRect(x: phaseLabelX, y: phaseLabelY, width: phaseLabelW, height: phaseLabelH)
    let phaseLabel = UILabel(frame: phaseLabelFrame)
    phaseLabel.text = "Phase: \(moment!.phaseDescription)"
    view.addSubview(phaseLabel)
    
    // Add weather conditions label
    
    let weatherLabelX: CGFloat = margin + diameter + margin
    let weatherLabelY: CGFloat = topBarOffset + margin + phaseLabelH + margin
    let weatherLabelW: CGFloat = viewBounds.width - weatherLabelX - margin
    let weatherLabelH: CGFloat = 20
    let weatherLabelFrame = CGRect(x: weatherLabelX, y: weatherLabelY, width: weatherLabelW, height: weatherLabelH)
    let weatherLabel = UILabel(frame: weatherLabelFrame)
    weatherLabel.text = "Weather: \(moment!.weather)"
    view.addSubview(weatherLabel)
    
    
    let timeFontSize: CGFloat = 16.0
    let dayFontSize : CGFloat = 14.0
    let infoFontSize: CGFloat = 14.0
    
    let timeFont = UIFont.boldSystemFontOfSize(CGFloat(timeFontSize))
    let dayFont = UIFont.systemFontOfSize(CGFloat(dayFontSize))
    let infoFont = UIFont.systemFontOfSize(CGFloat(infoFontSize))
    
    // Remove it later
    uMoment = Moment(start: moment!.start, end: moment!.end, angle: moment!.angle, phase: moment!.phase)
    pMoment = Moment(start: moment!.start, end: moment!.end, angle: moment!.angle, phase: moment!.phase)
    
    pMoment!.start = NSDate(timeInterval: 2 * 60 * 60, sinceDate: pMoment!.start)
    pMoment!.end = NSDate(timeInterval: 3 * 60 * 60, sinceDate: pMoment!.end)
    
    if settings.userTimezone?.rawOffset == nil { return showAlert("Error", message: "userTimezone == nil") }
    if settings.partnerTimezone?.rawOffset == nil { return showAlert("Error", message: "partnerTimezone == nil") }
    
    let us = CGFloat(uMoment!.start.timeIntervalSince1970)
    let ue = CGFloat(uMoment!.end.timeIntervalSince1970)
    let ps = CGFloat(pMoment!.start.timeIntervalSince1970)
    let pe = CGFloat(pMoment!.end.timeIntervalSince1970)
    
    var pixelsInSecond: CGFloat = 0
    
    let offset = CGPoint(x: 0, y: 5)
    
    var uMomentFrameX: CGFloat = margin
    var uMomentFrameY: CGFloat = topBarOffset + margin + diameter + margin + timeFontSize + dayFontSize + 2
    var uMomentFrameW: CGFloat = 0
    var uMomentFrameH: CGFloat = viewBounds.width / 4
    
    var pMomentFrameX: CGFloat = margin
    var pMomentFrameY: CGFloat = uMomentFrameY + uMomentFrameH + margin
    var pMomentFrameW: CGFloat = 0
    var pMomentFrameH: CGFloat = viewBounds.width / 4
    
    var bMomentFrameX: CGFloat = 0
    var bMomentFrameY: CGFloat = uMomentFrameY
    var bMomentFrameW: CGFloat = 0
    var bMomentFrameH: CGFloat = viewBounds.width / 2 + margin
    
    var lMomentFrameX: CGFloat = 0
    var lMomentFrameY: CGFloat = uMomentFrameY
    var lMomentFrameW: CGFloat = 0
    var lMomentFrameH: CGFloat = viewBounds.width / 2 + margin
    
    var rMomentFrameX: CGFloat = 0
    var rMomentFrameY: CGFloat = uMomentFrameY
    var rMomentFrameW: CGFloat = 0
    var rMomentFrameH: CGFloat = viewBounds.width / 2 + margin
    
    var momentFrameWidth: CGFloat = viewBounds.width - 2 * margin
    
    if us <= ps && ue <= pe {
      let momentDuration = pe - us
      pixelsInSecond = momentFrameWidth / momentDuration
      uMomentFrameX += 0
      uMomentFrameW = (ue - us) * pixelsInSecond
      pMomentFrameX += (ps - us) * pixelsInSecond
      pMomentFrameW = (pe - ps) * pixelsInSecond
      lMomentFrameX = uMomentFrameX
      lMomentFrameW = (ps - us) * pixelsInSecond
      bMomentFrameX = lMomentFrameX + lMomentFrameW
      bMomentFrameW = (ue - ps) * pixelsInSecond
      rMomentFrameX = bMomentFrameX + bMomentFrameW
      rMomentFrameW = (pe - ue) * pixelsInSecond
    }
    
    // Add user moment
    let uMomentFrame = CGRect(x: uMomentFrameX, y: uMomentFrameY, width: uMomentFrameW, height: uMomentFrameH)
    let uArcImage = uMoment!.asEllipticArc(uMomentFrame, offset: offset, maxDuration: uMoment!.duration, maxAngle: uMoment!.angle)
    let uMomentView = UIImageView(frame: uMomentFrame)
    uMomentView.contentMode = .TopLeft
    uMomentView.image = uArcImage
    view.addSubview(uMomentView)
    
    // Add partner's moment
    let pMomentFrame = CGRect(x: pMomentFrameX, y: pMomentFrameY, width: pMomentFrameW, height: pMomentFrameH)
    let pArcImage = pMoment!.asEllipticArc(pMomentFrame, offset: offset, maxDuration: pMoment!.duration, maxAngle: pMoment!.angle)
    let pMomentView = UIImageView(frame: pMomentFrame)
    pMomentView.contentMode = .TopLeft
    pMomentView.image = pArcImage
    view.addSubview(pMomentView)
    
    // Add best moment
    let bMomentFrame = CGRect(x: bMomentFrameX, y: bMomentFrameY, width: bMomentFrameW, height: bMomentFrameH)
    let bMomentView = UIView(frame: bMomentFrame)
    bMomentView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.2)
    view.addSubview(bMomentView)
    
    // Add best moment
    let lMomentFrame = CGRect(x: lMomentFrameX, y: lMomentFrameY, width: lMomentFrameW, height: lMomentFrameH)
    let lMomentView = UIView(frame: lMomentFrame)
    lMomentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.4)
    view.addSubview(lMomentView)
    
    // Add best moment
    let rMomentFrame = CGRect(x: rMomentFrameX, y: rMomentFrameY, width: rMomentFrameW, height: rMomentFrameH)
    let rMomentView = UIView(frame: rMomentFrame)
    rMomentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.4)
    view.addSubview(rMomentView)
    
    // User time and day
    let uStartingTime = NSDate(timeInterval: uTimeOffset!, sinceDate: moment!.start).timeDescription
    let uEndingTime   = NSDate(timeInterval: uTimeOffset!, sinceDate: moment!.end).timeDescription
    let uStartingDay  = NSDate(timeInterval: uTimeOffset!, sinceDate: moment!.start).dayDescription
    let uEndingDay    = NSDate(timeInterval: uTimeOffset!, sinceDate: moment!.end).dayDescription
    
    // Add user starting time label
    let uStartingTimeFrameY = topBarOffset + margin + diameter + margin
    let uStartingTimeFrame = CGRect(x: margin, y: uStartingTimeFrameY, width: viewBounds.width/4, height: timeFontSize)
    let uStartingTimeLabel = UILabel(frame: uStartingTimeFrame)
    uStartingTimeLabel.font = timeFont
    uStartingTimeLabel.textAlignment = .Left
    uStartingTimeLabel.text = uStartingTime
    view.addSubview(uStartingTimeLabel)
    
    // Add user starting day label
    let uStartingDayFrameY = topBarOffset + margin + diameter + margin + timeFontSize
    let uStartingDayFrame = CGRect(x: margin, y: uStartingDayFrameY, width: viewBounds.width/4, height: dayFontSize)
    let uStartingDayLabel = UILabel(frame: uStartingDayFrame)
    uStartingDayLabel.font = dayFont
    uStartingDayLabel.textAlignment = .Left
    uStartingDayLabel.text = uStartingDay
    view.addSubview(uStartingDayLabel)
    let uEndingOffset = viewBounds.width - margin - viewBounds.width/4
    
    // Add user ending time label
    let uEndingTimeFrameY = topBarOffset + margin + diameter + margin
    let uEndingTimeFrame = CGRect(x: uEndingOffset, y: uEndingTimeFrameY, width: viewBounds.width/4, height: timeFontSize)
    let uEndingTimeLabel = UILabel(frame: uEndingTimeFrame)
    uEndingTimeLabel.font = timeFont
    uEndingTimeLabel.textAlignment = .Right
    uEndingTimeLabel.text = uEndingTime
    view.addSubview(uEndingTimeLabel)
    
    // Add user ending day label if moon set in the other day
    if (uStartingDay != uEndingDay) {
      let uEndingDayFrameY = topBarOffset + margin + diameter + margin + timeFontSize
      let uEndingDayFrame = CGRect(x: uEndingOffset, y: uEndingDayFrameY, width: viewBounds.width/4, height: dayFontSize)
      let uEndingDayLabel = UILabel(frame: uEndingDayFrame)
      uEndingDayLabel.font = dayFont
      uEndingDayLabel.textColor = .lightGrayColor()
      uEndingDayLabel.textAlignment = .Right
      uEndingDayLabel.text = "the next day"
      view.addSubview(uEndingDayLabel)
    }
    
    // Add user timezone info label
    let uTimezoneOffset = viewBounds.width/2 - viewBounds.width/8
    let uTimezoneFrameY = topBarOffset + margin + diameter + margin
    let uTimezoneFrame = CGRect(x: uTimezoneOffset, y: uTimezoneFrameY, width: viewBounds.width/4, height: timeFontSize)
    let uTimezoneLabel = UILabel(frame: uTimezoneFrame)
    uTimezoneLabel.font = timeFont
    uTimezoneLabel.textAlignment = .Center
    uTimezoneLabel.text = settings.userTimezone!.description
    view.addSubview(uTimezoneLabel)

    // Add duration info label
    let uDurationOffset = viewBounds.width/2 - viewBounds.width/8
    let uDurationFrameY = topBarOffset + margin + diameter + margin + timeFontSize
    let uDurationFrame = CGRect(x: uDurationOffset, y: uDurationFrameY, width: viewBounds.width/4, height: infoFontSize)
    let uDurationLabel = UILabel(frame: uDurationFrame)
    uDurationLabel.font = infoFont
    uDurationLabel.textAlignment = .Center
    let momentDuration = moment!.duration
    var momentDurationText: String
    if momentDuration < 2 {
      momentDurationText = "\(momentDuration) hour"
    } else {
      momentDurationText = "\(momentDuration) hours"
    }
    uDurationLabel.text = momentDurationText
    view.addSubview(uDurationLabel)
    
    // Partner's time and day
    let pStartingTime = NSDate(timeInterval: pTimeOffset!, sinceDate: moment!.start).timeDescription
    let pEndingTime   = NSDate(timeInterval: pTimeOffset!, sinceDate: moment!.end).timeDescription
    let pStartingDay  = NSDate(timeInterval: pTimeOffset!, sinceDate: moment!.start).dayDescription
    let pEndingDay    = NSDate(timeInterval: pTimeOffset!, sinceDate: moment!.end).dayDescription
    
    // Add partner's starting time label
    let pStartingTimeFrameY = pMomentFrameY + pMomentFrameH
    let pStartingTimeFrame = CGRect(x: margin, y: pStartingTimeFrameY, width: viewBounds.width/4, height: timeFontSize)
    let pStartingTimeLabel = UILabel(frame: pStartingTimeFrame)
    pStartingTimeLabel.font = timeFont
    pStartingTimeLabel.textAlignment = .Left
    pStartingTimeLabel.text = pStartingTime
    view.addSubview(pStartingTimeLabel)
    
    // Add partner's starting day label
    let pStartingDayFrameY = pMomentFrameY + pMomentFrameH + timeFontSize
    let pStartingDayFrame = CGRect(x: margin, y: pStartingDayFrameY, width: viewBounds.width/4, height: dayFontSize)
    let pStartingDayLabel = UILabel(frame: pStartingDayFrame)
    pStartingDayLabel.font = dayFont
    pStartingDayLabel.textAlignment = .Left
    pStartingDayLabel.text = pStartingDay
    view.addSubview(pStartingDayLabel)
    let pEndingOffset = viewBounds.width - margin - viewBounds.width/4
    
    // Add partner's ending time label
    let pEndingTimeFrameY = pMomentFrameY + pMomentFrameH
    let pEndingTimeFrame = CGRect(x: pEndingOffset, y: pEndingTimeFrameY, width: viewBounds.width/4, height: timeFontSize)
    let pEndingTimeLabel = UILabel(frame: pEndingTimeFrame)
    pEndingTimeLabel.font = timeFont
    pEndingTimeLabel.textAlignment = .Right
    pEndingTimeLabel.text = pEndingTime
    view.addSubview(pEndingTimeLabel)
    
    // Add partner's ending day label if moon set in the other day
    if (pStartingDay != pEndingDay) {
      let pEndingDayFrameY = pMomentFrameY + pMomentFrameH + timeFontSize
      let pEndingDayFrame = CGRect(x: pEndingOffset, y: pEndingDayFrameY, width: viewBounds.width/4, height: dayFontSize)
      let pEndingDayLabel = UILabel(frame: pEndingDayFrame)
      pEndingDayLabel.font = dayFont
      pEndingDayLabel.textColor = .lightGrayColor()
      pEndingDayLabel.textAlignment = .Right
      pEndingDayLabel.text = "the next day"
      view.addSubview(pEndingDayLabel)
    }
    
    // Add partner's timezone info label
    let pTimezoneOffset = viewBounds.width/2 - viewBounds.width/8
    let pTimezoneFrameY = pMomentFrameY + pMomentFrameH
    let pTimezoneFrame = CGRect(x: pTimezoneOffset, y: pTimezoneFrameY, width: viewBounds.width/4, height: timeFontSize)
    let pTimezoneLabel = UILabel(frame: pTimezoneFrame)
    pTimezoneLabel.font = timeFont
    pTimezoneLabel.textAlignment = .Center
    pTimezoneLabel.text = settings.partnerTimezone!.description
    view.addSubview(pTimezoneLabel)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}