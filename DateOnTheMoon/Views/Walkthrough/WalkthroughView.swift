//
//  WalkthroughView.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 09/03/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit

class WalkthroughView: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  let pageTitles = [
    "Welcome to the most super awesome app in the world! Now you will go through a quick tutorial.",
    "To begin working with this super awesome app you have to set your and your partner's location. So go to the settings.",
    "After you've chosen your and your partner's location. Go to the moments view.",
    "Pick the most perfect moment from the list and share it with your partner.",
    "Now you are ready to get into this super awesome app!"
  ]
  
  let pageImages = [
    "moon5.jpg",
    "moon6.jpg",
    "moon6.jpg",
    "moon6.jpg",
    ""
  ]
  
  var completion: (() -> ())?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    delegate = self
    
    let startingViewController = viewControllerAtIndex(0)
    let viewControllers: NSArray = [startingViewController!]
    setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: false, completion: nil)
    
  }
  
  func viewControllerAtIndex(index: Int) -> UIViewController? {
    if self.pageTitles.count < 0 || index >= self.pageTitles.count { return nil }
    
    let pageViewController = WalkthroughTipView()
    
    pageViewController.index = index
    pageViewController.tipTitleText = pageTitles[index]
    pageViewController.tipImageName = pageImages[index]
    pageViewController.completion = completion
    return pageViewController
  }
  
  /* UIPageViewControllerDataSource */
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    let pageController = viewController as! WalkthroughTipView
    if pageController.index <= 0 { return nil }
    
    return self.viewControllerAtIndex(pageController.index - 1)
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    let pageController = viewController as! WalkthroughTipView
    if(pageController.index + 1 >= self.pageImages.count) { return nil }
    
    return viewControllerAtIndex(pageController.index + 1)
  }
  
  func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return pageTitles.count
  }
  
  func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return 0
  }
}
