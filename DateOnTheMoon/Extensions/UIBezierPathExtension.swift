//
//  UIBezierPathExtension.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 05/01/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit

extension UIBezierPath {
    func strokeImage(maxWidth: Double, maxHeight: Double, frame: CGRect) -> UIImage? {
        // adjust bounds to account for extra space needed for lineWidth
        let width = self.bounds.size.width + self.lineWidth * 2
        let height = self.bounds.size.height + self.lineWidth * 2
        let bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: width, height: height)
        
        // create a view to draw the path in
        let view = UIView(frame: bounds)
        
        // begin graphics context for drawing
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.mainScreen().scale)
        
        // configure the view to render in the graphics context
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        // get reference to the graphics context
        let context = UIGraphicsGetCurrentContext()
        
        // translate matrix so that path will be centered in bounds
        CGContextTranslateCTM(context, -(bounds.origin.x - self.lineWidth), -(bounds.origin.y - self.lineWidth))
        
        // draw the stroke
        self.stroke()
        
        // get an image of the graphics context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the context
        UIGraphicsEndImageContext()
        
        let offsetX = (Double(width) - maxWidth) / 2
        let offsetY = Double(frame.origin.y)
        
        let scale = Double(UIScreen.mainScreen().scale)
        
        // create an image from
        var areaWidth: Double
        if offsetX < 0 {
            areaWidth = scale * (Double(width) - offsetX)
        } else {
            areaWidth = scale * Double(width)
        }
        
        let fromImageArea = CGRect(x: 0, y: 0, width: areaWidth, height: offsetY)// new image
        let mySubimage  = CGImageCreateWithImageInRect(image.CGImage, fromImageArea)
        let myRect      = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
        CGContextDrawImage(context, myRect, mySubimage)
        var momentImage = UIImage(CGImage: mySubimage)
        
        // resize image
        let newWidth = Double(frame.width)
        let newHeight = offsetY
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)
        if (momentImage == nil) {
            println("moment image is nil")
        }
        momentImage?.drawInRect(CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

