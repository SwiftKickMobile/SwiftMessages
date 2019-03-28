//
//  Stevia+Alignment.swift
//  Stevia
//
//  Created by Sacha Durand Saint Omer on 10/02/16.
//  Copyright © 2016 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

/** Aligns an array of views Horizontally (on the X Axis)
 
 Example Usage:
 ```
 align(horizontally: label,button,arrow)
 ```
 
 Ca also be used directly on horizontal layouts since they return the array of views :
 ```
 align(horizontally: |-image1-image2-image3-|)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(horizontally views: UIView...) -> [UIView] {
    return align(horizontally: views)
}

@available(*, deprecated: 4.1.0, renamed: "align(horizontally:)")
@discardableResult
public func alignHorizontally(_ views: UIView...) -> [UIView] {
    return align(horizontally: views)
}

/** Aligns an array of views Horizontally (on the X Axis)
 
 Example Usage:
 ```
 align(horizontally: label,button,arrow)
 ```
 
 Ca also be used directly on horizontal layouts since they return the array of views :
 ```
 align(horizontally: |-image1-image2-image3-|)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(horizontally views: [UIView]) -> [UIView] {
    align(.horizontal, views: views)
    return views
}

@available(*, deprecated: 4.1.0, renamed: "align(horizontally:)")
@discardableResult
public func alignHorizontally(_ views: [UIView]) -> [UIView] {
    align(.horizontal, views: views)
    return views
}

/** Aligns an array of views Vertically (on the Y Axis)
 
 Example Usage:
 ```
 align(vertically: label,field,button)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
public func align(vertically views: UIView...) {
    align(vertically: views)
}

@available(*, deprecated: 4.1.0, renamed: "align(vertically:)")
public func alignVertically(_ views: UIView...) {
    align(vertically: views)
}

/** Aligns an array of views Vertically (on the Y Axis)
 
 Example Usage:
 ```
 align(vertically: label,field,button)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
public func align(vertically views: [UIView]) {
    align(.vertical, views: views)
}

@available(*, deprecated: 4.1.0, renamed: "align(vertically:)")
public func alignVertically(_ views: [UIView]) {
    align(.vertical, views: views)
}

/** Aligns the center of two views
 
 Example Usage:
 ```
 alignCenter(button, with:image)
 ```
 */
public func alignCenter(_ v1: UIView, with v2: UIView) {
    alignHorizontally(v1, with: v2)
    alignVertically(v1, with: v2)
}

/** Aligns two views Horizontall (on the X Axis)
 
 Example Usage:
 ```
 alignHorizontally(label, with:field)
 ```
 
 */
public func alignHorizontally(_ v1: UIView, with v2: UIView, offset: CGFloat = 0) {
    align(.horizontal, v1: v1, with: v2, offset: offset)
}

/** Aligns two views Vertically (on the Y Axis)
 
 Example Usage:
 ```
 alignVertically(label, with:field)
 ```
 
 */
public func alignVertically(_ v1: UIView, with v2: UIView, offset: CGFloat = 0) {
    align(.vertical, v1: v1, with: v2, offset: offset)
}

private func align(_ axis: NSLayoutConstraint.Axis, views: [UIView]) {
    for (i, v) in views.enumerated() where views.count > i+1 {
        let v2 = views[i+1]
        if axis == .horizontal {
            alignHorizontally(v, with: v2)
        } else {
            alignVertically(v, with: v2)
        }
    }
}

private func align(_ axis: NSLayoutConstraint.Axis, v1: UIView, with v2: UIView, offset: CGFloat) {
    if let spv = v1.superview {
        let center: NSLayoutConstraint.Attribute = axis == .horizontal ? .centerY : .centerX
        let c = constraint(item: v1, attribute: center, toItem: v2, constant: offset)
        spv.addConstraint(c)
    }
}

// MARK: Align sides

/** Aligns tops of an array of views
 
 Example Usage:
 ```
 align(tops: label,button,arrow)
 ```
 
 Ca also be used directly on horizontal layouts since they return the array of views :
 ```
 align(tops: |-image1-image2-image3-|)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(tops views: UIView...) -> [UIView] {
    return align(tops: views)
}

@available(*, deprecated: 4.1.0, renamed: "align(tops:)")
@discardableResult
public func alignTops(_ views: UIView...) -> [UIView] {
    return align(tops: views)
}

/** Aligns tops of an array of views
 
 Example Usage:
 ```
 align(tops: label,button,arrow)
 ```
 
 Ca also be used directly on horizontal layouts since they return the array of views :
 ```
 align(tops: |-image1-image2-image3-|)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(tops views: [UIView]) -> [UIView] {
    align(.top, views: views)
    return views
}

@available(*, deprecated: 4.1.0, renamed: "align(tops:)")
@discardableResult
public func alignTops(_ views: [UIView]) -> [UIView] {
    align(.top, views: views)
    return views
}

/** Aligns bottoms of an array of views
 
 Example Usage:
 ```
 align(bottoms: label,button,arrow)
 ```
 
 Ca also be used directly on horizontal layouts since they return the array of views :
 ```
 align(bottoms: |-image1-image2-image3-|)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(bottoms views: UIView...) -> [UIView] {
    return align(bottoms: views)
}

@available(*, deprecated: 4.1.0, renamed: "align(bottoms:)")
@discardableResult
public func alignBottoms(_ views: UIView...) -> [UIView] {
    return align(bottoms: views)
}

/** Aligns bottoms of an array of views
 
 Example Usage:
 ```
 align(bottoms: label,button,arrow)
 ```
 
 Ca also be used directly on horizontal layouts since they return the array of views :
 ```
 align(bottoms: |-image1-image2-image3-|)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(bottoms views: [UIView]) -> [UIView] {
    align(.bottom, views: views)
    return views
}

@available(*, deprecated: 4.1.0, renamed: "align(bottoms:)")
@discardableResult
public func alignBottoms(_ views: [UIView]) -> [UIView] {
    align(.bottom, views: views)
    return views
}

/** Aligns left sides of an array of views
 
 Example Usage:
 ```
 align(lefts: label,field,button)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(lefts views: UIView...) -> [UIView] {
    return align(lefts: views)
}

@available(*, deprecated: 4.1.0, renamed: "align(lefts:)")
@discardableResult
public func alignLefts(_ views: UIView...) -> [UIView] {
    return align(lefts: views)
}

/** Aligns left sides of an array of views
 
 Example Usage:
 ```
 align(lefts: label,field,button)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(lefts views: [UIView]) -> [UIView] {
    align(.left, views: views)
    return views
}

@available(*, deprecated: 4.1.0, renamed: "align(lefts:)")
@discardableResult
public func alignLefts(_ views: [UIView]) -> [UIView] {
    align(.left, views: views)
    return views
}

/** Aligns right sides of an array of views
 
 Example Usage:
 ```
 align(rights: label,field,button)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(rights views: UIView...) -> [UIView] {
    return align(rights: views)
}

@available(*, deprecated: 4.1.0, renamed: "align(rights:)")
@discardableResult
public func alignRights(_ views: UIView...) -> [UIView] {
    return align(rights: views)
}

/** Aligns right sides of an array of views
 
 Example Usage:
 ```
 align(rights: label,field,button)
 ```
 
 - Returns: The array of views, enabling chaining,
 
 */
@discardableResult
public func align(rights views: [UIView]) -> [UIView] {
    align(.right, views: views)
    return views
}

@available(*, deprecated: 4.1.0, renamed: "align(rights:)")
@discardableResult
public func alignRights(_ views: [UIView]) -> [UIView] {
    align(.right, views: views)
    return views
}

@discardableResult
public func align(_ attribute: NSLayoutConstraint.Attribute, views: [UIView]) -> [UIView] {
    for (i, v) in views.enumerated() where views.count > i+1 {
        let v2 = views[i+1]
        if let spv = v.superview {
            let c = constraint(item: v, attribute: attribute, toItem: v2)
            spv.addConstraint(c)
        }
    }
    return views
}
