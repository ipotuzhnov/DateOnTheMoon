//
//  DetailMomentView.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 14/03/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit

class DetailMomentView: UIViewController {
  var moment: Moment?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidLayoutSubviews() {
    if moment == nil { return }
    
    let viewBounds = self.view.bounds;
    let topBarOffset = self.topLayoutGuide.length;
    
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
    
    // Vertical margins
    
    let vviewtFrame = CGRect(x: 0, y: topBarOffset, width: viewBounds.width, height: margin)
    let vviewt = UIView(frame: vviewtFrame)
    vviewt.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    view.addSubview(vviewt)
    
    let vviewbFrame = CGRect(x: 0, y: viewBounds.height - margin, width: viewBounds.width, height: margin)
    let vviewb = UIView(frame: vviewbFrame)
    vviewb.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    view.addSubview(vviewb)
    
    // Horizontal margins
    
    let hviewlFrame = CGRect(x: 0, y: topBarOffset, width: margin, height: viewBounds.height)
    let hviewl = UIView(frame: hviewlFrame)
    hviewl.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
    view.addSubview(hviewl)
    
    let hviewrFrame = CGRect(x: viewBounds.width - margin, y: topBarOffset, width: margin, height: viewBounds.height)
    let hviewr = UIView(frame: hviewrFrame)
    hviewr.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
    view.addSubview(hviewr)
    
    // Vertical margins for moon
    
    let vmoonbx: CGFloat = 0
    let vmoonby: CGFloat = topBarOffset + margin + diameter
    let vmoonbw: CGFloat = margin + diameter + margin
    let vmoonbh: CGFloat = margin
    let vmoonbFrame = CGRect(x: vmoonbx, y: vmoonby, width: vmoonbw, height: vmoonbh)
    let vmoonb = UIView(frame: vmoonbFrame)
    vmoonb.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    view.addSubview(vmoonb)
    
    // Horizontal margins for moon
    
    let hmoonbx: CGFloat = margin + diameter
    let hmoonby: CGFloat = topBarOffset
    let hmoonbw: CGFloat = margin
    let hmoonbh: CGFloat = margin + diameter + margin
    let hmoonrFrame = CGRect(x: hmoonbx, y: hmoonby, width: hmoonbw, height: hmoonbh)
    let hmoonr = UIView(frame: hmoonrFrame)
    hmoonr.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
    view.addSubview(hmoonr)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}