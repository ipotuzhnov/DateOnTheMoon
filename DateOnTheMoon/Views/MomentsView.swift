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
    tableView.rowHeight = screenWidth / 4.0
    
    addRefreshControll()
    
    updateMoments()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /* Presents simple alert.
  * @param {String} title The title for alert.
  * @param {String} message The message for alert.
  */
  func showAlert(title: String, message: String) {
    var alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Ok", style: .Default) {
      (action: UIAlertAction!) in
      println("Handle Ok logic here")
      })
    
    /*
    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
    println("Handle Cancel Logic here")
    }))
    */
    
    presentViewController(alert, animated: true, completion: nil)
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
        
        self.tableView.reloadData()
      }
    }
  }
  
  func refreshTableView(sender: AnyObject) {
    // Do refreshing
    updateMoments()
    
    return
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let delay = 0.5
      NSThread.sleepForTimeInterval(delay)
      
      dispatch_async(dispatch_get_main_queue()) {
        self.refreshControl.endRefreshing()
      }
    })
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showMomentDetails" {
      let destinationView = segue.destinationViewController as DetailMomentView
      destinationView.moment = selectedMoment
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
    
    let cellWidth = Double(tableView.contentSize.width)
    let cellHeight = Double(tableView.rowHeight)
    
    let leftMargin = 20.0
    
    // Default font sizes
    let timeFontSize = momentsModel.timeFontSize
    let dayFontSize  = momentsModel.dayFontSize
    let infoFontSize = momentsModel.infoFontSize
    
    // Draw moment elliptic arc
    let momentFrame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
    let offset = CGPoint(x: leftMargin + 10, y: infoFontSize * 2)
    let maxAngle = momentsModel.maxAngle
    let maxDuration = momentsModel.maxDuration
    
    // Add moment image
    let arcImage = moment.asEllipticArc(momentFrame, offset: offset, maxDuration: maxDuration, maxAngle: maxAngle)
    let momentView = UIImageView(frame: momentFrame)
    momentView.contentMode = .TopLeft
    momentView.image = arcImage
    cell.addSubview(momentView)
    
    let timeFont = UIFont.boldSystemFontOfSize(CGFloat(timeFontSize))
    let dayFont = UIFont.systemFontOfSize(CGFloat(dayFontSize))
    let infoFont = UIFont.systemFontOfSize(CGFloat(infoFontSize))
    
    // Add moon image
    let moonFrame = CGRect(x: 2, y: 0, width: 18, height: 16)
    let moonMargin: CGFloat = 2
    let moonImage = moment.drawMoonIn(moonFrame, margin: moonMargin, color: .whiteColor())
    let moonView = UIImageView(frame: CGRect(x: 2, y: 0, width: 18, height: 16))
    moonView.image = moonImage
    moonView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI/10), 0, 0, 1)
    cell.addSubview(moonView)
    
    // Add starting time label
    let startingTimeFrame = CGRect(x: leftMargin, y: 0.0, width: cellWidth/4, height: timeFontSize)
    let startingTimeLabel = UILabel(frame: startingTimeFrame)
    startingTimeLabel.font = timeFont
    startingTimeLabel.textAlignment = .Left
    startingTimeLabel.text = momentsModel.getStartingTime(index)
    cell.addSubview(startingTimeLabel)
    
    // Add starting day label
    let startingDayFrame = CGRect(x: leftMargin, y: timeFontSize, width: cellWidth/4, height: dayFontSize)
    let startingDayLabel = UILabel(frame: startingDayFrame)
    startingDayLabel.font = dayFont
    startingDayLabel.textAlignment = .Left
    startingDayLabel.text = momentsModel.getStartingDay(index)
    cell.addSubview(startingDayLabel)
    let endingOffset = cellWidth - leftMargin - cellWidth/4
    
    // Add ending time label
    let endingTimeFrame = CGRect(x: endingOffset, y: 0.0, width: cellWidth/4, height: timeFontSize)
    let endingTimeLabel = UILabel(frame: endingTimeFrame)
    endingTimeLabel.font = timeFont
    endingTimeLabel.textAlignment = .Right
    endingTimeLabel.text = momentsModel.getEndingTime(index)
    cell.addSubview(endingTimeLabel)
    
    // Add ending day label if moon set in the other day
    if (momentsModel.getStartingDay(index) != momentsModel.getEndingDay(index)) {
      let endingDayFrame = CGRect(x: endingOffset, y: timeFontSize, width: cellWidth/4, height: dayFontSize)
      let endingDayLabel = UILabel(frame: endingDayFrame)
      endingDayLabel.font = dayFont
      endingDayLabel.textColor = .lightGrayColor()
      endingDayLabel.textAlignment = .Right
      endingDayLabel.text = "the next day"
      cell.addSubview(endingDayLabel)
    }
    let infoOffset = cellWidth/2 - cellWidth/8
    
    // Add duration info label
    let durationFrame = CGRect(x: infoOffset, y: 0.0, width: cellWidth/4, height: infoFontSize)
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
    let angleFrame = CGRect(x: infoOffset, y: infoFontSize, width: cellWidth/4, height: infoFontSize)
    let angleLabel = UILabel(frame: angleFrame)
    angleLabel.font = infoFont
    angleLabel.textAlignment = .Center
    angleLabel.text = "\(Int(momentsModel.getMomentAngle(index)))\u{00B0}"
    cell.addSubview(angleLabel)
    
    cell.accessoryType = .DisclosureIndicator
    cell.selectionStyle = .None
    
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
