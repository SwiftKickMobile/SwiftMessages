//
//  Stevia+Baselines.swift
//  Stevia
//
//  Created by Sacha on 09/09/2018.
//  Copyright © 2018 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

/** Aligns an array of views by their lastBaselines (on the Y Axis)
 
 Example Usage:
 ```
 align(lastBaselines: label1, label2, label3)
 ```
 
 Can also be used directly on horizontal layouts since they return the array of views :
 ```
 align(lastBaselines: |-label1-label2-label3-|)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(lastBaselines views: UIView...) -> [UIView] {
    return align(lastBaselines: views)
}

@discardableResult
public func align(lastBaselines views: [UIView]) -> [UIView] {
    for (i, v) in views.enumerated() where views.count > i+1 {
        let v2 = views[i+1]
        if #available(iOS 9.0, *) {
            v.lastBaselineAnchor.constraint(equalTo: v2.lastBaselineAnchor).isActive = true
        } else if let spv = v.superview {
            let c = constraint(item: v, attribute: .lastBaseline, toItem: v2)
            spv.addConstraint(c)
        }
    }
    return views
}

/** Aligns an array of views by their firstBaselines (on the Y Axis)
 
 Example Usage:
 ```
 align(firstBaselines: label1, label2, label3)
 ```
 
 Can also be used directly on horizontal layouts since they return the array of views :
 ```
 align(firstBaselines: |-label1-label2-label3-|)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(firstBaselines views: UIView...) -> [UIView] {
    return align(firstBaselines: views)
}

@discardableResult
public func align(firstBaselines views: [UIView]) -> [UIView] {
    for (i, v) in views.enumerated() where views.count > i+1 {
        let v2 = views[i+1]
        if #available(iOS 9.0, *) {
            v.firstBaselineAnchor.constraint(equalTo: v2.firstBaselineAnchor).isActive = true
        } else if let spv = v.superview {
            let c = constraint(item: v, attribute: .firstBaseline, toItem: v2)
            spv.addConstraint(c)
        }
    }
    return views
}
