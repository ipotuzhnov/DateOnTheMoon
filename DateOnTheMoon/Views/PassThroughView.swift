//
//  PassThroughView.swift
//  Date on the Moon
//
//  Created by Ilya Potuzhnov on 07/03/15.
//  Copyright (c) 2015 Ilya Potuzhnov. All rights reserved.
//

import UIKit

/* Pass through view.
 * http://stackoverflow.com/questions/3046813/how-can-i-click-a-button-behind-a-transparent-uiview
 */

class PassThroughView: UIView {
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
                return true
            }
        }
        return false
    }
}