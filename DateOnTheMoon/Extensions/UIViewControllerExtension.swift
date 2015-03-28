//
//  UIViewControllerExtension.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 28/03/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit

extension UIViewController {
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

}
