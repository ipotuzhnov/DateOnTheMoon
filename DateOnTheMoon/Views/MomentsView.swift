//
//  MomentsView.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 05/01/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit

class MomentsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet weak var tableView: UITableView!
  
  var refreshControl: UIRefreshControl!
  var selectedMoment: Moment?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let screenRect = UIScreen.mainScreen().bounds
    let screenWidth = screenRect.size.width
    tableView.rowHeight = screenWidth / 3.0
    tableView.layoutMargins = UIEdgeInsetsZero
    
    addRefreshControll()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    refreshControl.beginRefreshing()
    updateMoments()
  }
  
  func addRefreshControll() {
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refreshTableView:", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
  }
  
  func updateMoments() {
    momentsModel.getMoments {
      (error) in
      dispatch_async(dispatch_get_main_queue()) {
        if error != nil { return self.showAlert("Failed to load moments!", message: error!) }
        
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
      }
    }
  }
  
  func refreshTableView(sender: AnyObject) {
    // Do refreshing
    updateMoments()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showMomentDetails" {
      let destinationView = segue.destinationViewController as? DetailMomentView
      destinationView?.moment = selectedMoment
    }
  }
  
  /* UITableViewDelegate */
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedMoment = momentsModel.moments[indexPath.row]
    performSegueWithIdentifier("showMomentDetails", sender: self)
  }
  
  // MARK: - UITableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return momentsModel.moments.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let index = indexPath.row
    let moment = momentsModel.moments[index]
    let cell = UITableViewCell(style: .Value1, reuseIdentifier: "momentCell")
    
    let cellWidth = CGFloat(tableView.contentSize.width)
    let cellHeight = CGFloat(tableView.rowHeight)
    
    // Default font sizes
    let timeFontSize = CGFloat(momentsModel.timeFontSize)
    let dayFontSize  = CGFloat(momentsModel.dayFontSize)
    let infoFontSize = CGFloat(momentsModel.infoFontSize)
    
    let timeFont = UIFont.boldSystemFontOfSize(CGFloat(timeFontSize))
    let dayFont = UIFont.systemFontOfSize(CGFloat(dayFontSize))
    let infoFont = UIFont.systemFontOfSize(CGFloat(infoFontSize))
    
    let padding: CGFloat = 4
    
    let topMargin: CGFloat = 10
    let timeFrameOffset: CGFloat = topMargin + padding + timeFontSize
    let infoFrameOffset: CGFloat = topMargin + padding + infoFontSize
    
    let moonDiameter: CGFloat = timeFontSize + padding + dayFontSize
    let moonMargin: CGFloat = 10
    let leftMargin: CGFloat = moonMargin + moonDiameter + moonMargin
    
    // Draw moment elliptic arc
    let momentFrame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
    let offset = CGPoint(x: leftMargin, y: infoFrameOffset + padding + infoFontSize)
    let maxAngle = momentsModel.maxAngle
    let maxDuration = momentsModel.maxDuration
    
    // Add moment image
    let arcImage = moment.asEllipticArc(momentFrame, offset: offset, maxDuration: maxDuration, maxAngle: maxAngle)
    let momentView = UIImageView(frame: momentFrame)
    momentView.contentMode = .TopLeft
    momentView.image = arcImage
    cell.addSubview(momentView)
    
    // Add moon image
    let moonFrame = CGRect(x: 0, y: 0, width: moonDiameter, height: moonDiameter)
    let moonImage = moment.drawMoonIn(moonFrame, margin: 0, color: .whiteColor())
    let moonView = UIImageView(frame: CGRect(x: moonMargin, y: topMargin, width: moonDiameter, height: moonDiameter))
    moonView.image = moonImage
    moonView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI/10), 0, 0, 1)
    cell.addSubview(moonView)
    
    // Add starting time label
    let startingTimeFrame = CGRect(x: leftMargin, y: topMargin, width: cellWidth/4, height: timeFontSize)
    let startingTimeLabel = UILabel(frame: startingTimeFrame)
    startingTimeLabel.font = timeFont
    startingTimeLabel.textAlignment = .Left
    startingTimeLabel.text = momentsModel.getStartingTime(index)
    cell.addSubview(startingTimeLabel)
    
    // Add starting day label
    let startingDayFrame = CGRect(x: leftMargin, y: timeFrameOffset, width: cellWidth/4, height: dayFontSize)
    let startingDayLabel = UILabel(frame: startingDayFrame)
    startingDayLabel.font = dayFont
    startingDayLabel.textAlignment = .Left
    startingDayLabel.text = momentsModel.getStartingDay(index)
    cell.addSubview(startingDayLabel)
    let endingOffset = cellWidth - leftMargin + moonMargin + padding - cellWidth/4
    
    // Add ending time label
    let endingTimeFrame = CGRect(x: endingOffset, y: topMargin, width: cellWidth/4, height: timeFontSize)
    let endingTimeLabel = UILabel(frame: endingTimeFrame)
    endingTimeLabel.font = timeFont
    endingTimeLabel.textAlignment = .Right
    endingTimeLabel.text = momentsModel.getEndingTime(index)
    cell.addSubview(endingTimeLabel)
    
    // Add ending day label if moon set in the other day
    if (momentsModel.getStartingDay(index) != momentsModel.getEndingDay(index)) {
      let endingDayFrame = CGRect(x: endingOffset, y: timeFrameOffset, width: cellWidth/4, height: dayFontSize)
      let endingDayLabel = UILabel(frame: endingDayFrame)
      endingDayLabel.font = dayFont
      endingDayLabel.textColor = .lightGrayColor()
      endingDayLabel.textAlignment = .Right
      endingDayLabel.text = "the next day"
      cell.addSubview(endingDayLabel)
    }
    let infoOffset = cellWidth/2 - cellWidth/8
    
    // Add duration info label
    let durationFrame = CGRect(x: infoOffset, y: topMargin, width: cellWidth/4, height: infoFontSize)
    let durationLabel = UILabel(frame: durationFrame)
    durationLabel.font = infoFont
    durationLabel.textAlignment = .Center
    let momentDuration = momentsModel.getMomentDuration(index)
    var momentDurationText: String
    if momentDuration < 2 {
      momentDurationText = "\(momentDuration) hour"
    } else {
      momentDurationText = "\(momentDuration) hours"
    }
    durationLabel.text = momentDurationText
    cell.addSubview(durationLabel)
    
    // Add angle info label
    let angleFrame = CGRect(x: infoOffset, y: infoFrameOffset, width: cellWidth/4, height: infoFontSize)
    let angleLabel = UILabel(frame: angleFrame)
    angleLabel.font = infoFont
    angleLabel.textAlignment = .Center
    angleLabel.text = "\(Int(momentsModel.getMomentAngle(index)))\u{00B0}"
    cell.addSubview(angleLabel)
    
    cell.accessoryType = .DisclosureIndicator
    cell.selectionStyle = .None
    cell.layoutMargins = UIEdgeInsetsZero
    
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
  
}
