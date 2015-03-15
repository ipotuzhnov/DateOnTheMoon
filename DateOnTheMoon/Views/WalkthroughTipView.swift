//
//  WalkthroughTipView.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 09/03/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit

class WalkthroughTipView: UIViewController {
    var index = 0
    var tipTitleText: String?
    var tipImageName: String?
    var completion: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor()
        
        let titleViewHeight: CGFloat = 140
        
        if let text = tipTitleText {
            let titleViewFrame = CGRect(x: 20, y: 0, width: view.frame.width - 40, height: titleViewHeight)
            let titleView = UILabel(frame: titleViewFrame)
            titleView.text = text
            titleView.textAlignment = .Center
            titleView.numberOfLines = 0
            view.addSubview(titleView)
        }
        
        if index == 4 {
            let button = UIButton.buttonWithType(.System) as UIButton
            button.frame = CGRect(x: 20, y: titleViewHeight + 80, width: view.frame.width - 40, height: 50)
            button.setTitle("Let's start off!", forState: UIControlState.Normal)
            button.addTarget(self, action: "goToTheSettings:", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(button)
            
            return
        }
        
        if let name = tipImageName {
            let height: CGFloat = view.frame.height - (titleViewHeight + 60)
            let width: CGFloat = height / 2
            let y: CGFloat = titleViewHeight + 20
            let x = (view.frame.width - width) / 2
            let imageViewFrame = CGRect(x: x, y: y, width: width, height: height)
            let imageView = UIImageView(frame: imageViewFrame)
            imageView.image = UIImage(named: name)
            view.addSubview(imageView)
        }
    }
    
    func goToTheSettings(sender: UIButton!) {
        if let presentSettings = completion {
            presentSettings()
        }
    }
}
