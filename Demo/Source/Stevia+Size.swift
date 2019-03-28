//
//  Stevia+Size.swift
//  Stevia
//
//  Created by Sacha Durand Saint Omer on 10/02/16.
//  Copyright © 2016 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

public extension UIView {
    
    /**
     Adds an Autolayout constraint for sizing the view.
     
     ```
     image.size(100)
     image.size(100%)
     
     // is equivalent to
     
     image.width(100).height(100)
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func size(_ points: CGFloat) -> UIView {
        width(points)
        height(points)
        return self
    }
    
    /**
     Adds an Autolayout constraint for setting the view's height.
     
     ```
     image.height(100)
     
     // is equivalent to
     
     image ~ 100
     
     // Flexible margins
     image.height(<=100)
     image.height(>=100)
     image.height(100%)
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func height(_ points: CGFloat) -> UIView {
        return size(.height, points: points)
    }
    
    /**
     Adds an Autolayout constraint for setting the view's width.
     
     ```
     image.width(100)
     image.width(<=100)
     image.width(>=100)
     image.width(100%)
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func width(_ points: CGFloat) -> UIView {
        return size(.width, points: points)
    }
    
    /**
     Adds an Autolayout constraint for setting the view's height.
     
     ```
     image.height(100)
     
     // is equivalent to
     
     image ~ 100
     
     // Flexible margins
     image.height(<=100)
     image.height(>=100)
     image.height(100%)
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func height(_ fm: SteviaFlexibleMargin) -> UIView {
        return size(.height, relatedBy: fm.relation, points: fm.points)
    }
    
    /**
     Adds an Autolayout constraint for setting the view's width.
     
     ```
     image.width(100)
     image.width(<=100)
     image.width(>=100)
     image.width(100%)
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func width(_ fm: SteviaFlexibleMargin) -> UIView {
        return size(.width, relatedBy: fm.relation, points: fm.points)
    }
    
    fileprivate func size(_ attribute: NSLayoutConstraint.Attribute,
                          relatedBy: NSLayoutConstraint.Relation = .equal,
                          points: CGFloat) -> UIView {
        let c = constraint(item: self,
                           attribute: attribute,
                           relatedBy: relatedBy,
                           constant: points)
        if let spv = superview {
            spv.addConstraint(c)
        } else {
            addConstraint(c)
        }
        return self
    }
}

/**
 Enforces an array of views to keep the same size.
 
 ```
 equal(sizes: image1, image2, image3)
 ```
 
 - Returns: The views enabling chaining.
 
 */
@discardableResult
public func equal(sizes views: UIView...) -> [UIView] {
    return equal(sizes: views)
}

@available(*, deprecated: 4.1.0, renamed:"equal(sizes:)")
@discardableResult
public func equalSizes(_ views: UIView...) -> [UIView] {
    return equal(sizes: views)
}

/**
 Enforces an array of views to keep the same size.
 
 ```
 equal(sizes: image1, image2, image3)
 ```
 
 - Returns: The views enabling chaining.
 
 */
@discardableResult
public func equal(sizes views: [UIView]) -> [UIView] {
    equal(heights: views)
    equal(widths: views)
    return views
}

@available(*, deprecated: 4.1.0, renamed:"equal(sizes:)")
@discardableResult
public func equalSizes(_ views: [UIView]) -> [UIView] {
    equal(heights: views)
    equal(widths: views)
    return views
}

/**
 Enforces an array of views to keep the same widths.
 
 ```
 equal(widths: image1, image2, image3)
 ```
 
 - Returns: The views enabling chaining.
 
 */
@discardableResult
public func equal(widths views: UIView...) -> [UIView] {
    return equal(widths: views)
}

@available(*, deprecated: 4.1.0, renamed:"equal(widths:)")
@discardableResult
public func equalWidths(_ views: UIView...) -> [UIView] {
    return equal(widths: views)
}

/**
 Enforces an array of views to keep the same widths.
 
 ```
 equal(widths: image1, image2, image3)
 ```
 
 - Returns: The views enabling chaining.
 
 */
@discardableResult
public func equal(widths views: [UIView]) -> [UIView] {
    equal(.width, views: views)
    return views
}

@available(*, deprecated: 4.1.0, renamed:"equal(widths:)")
@discardableResult
public func equalWidths(_ views: [UIView]) -> [UIView] {
    equal(.width, views: views)
    return views
}

/**
 Enforces an array of views to keep the same heights.
 
 ```
 equal(heights: image1, image2, image3)
 ```
 
 - Returns: The views enabling chaining.
 
 */
@discardableResult
public func equal(heights views: UIView...) -> [UIView] {
    return equal(heights: views)
}

@available(*, deprecated: 4.1.0, renamed:"equal(heights:)")
@discardableResult
public func equalHeights(_ views: UIView...) -> [UIView] {
    return equal(heights: views)
}

/**
 Enforces an array of views to keep the same heights.
 
 ```
 equal(heights: image1, image2, image3)
 ```
 
 - Returns: The views enabling chaining.
 
 */
@discardableResult
public func equal(heights views: [UIView]) -> [UIView] {
    equal(.height, views: views)
    return views
}

@available(*, deprecated: 4.1.0, renamed:"equal(heights:)")
@discardableResult
public func equalHeights(_ views: [UIView]) -> [UIView] {
    equal(.height, views: views)
    return views
}

private func equal(_ attribute: NSLayoutConstraint.Attribute, views: [UIView]) {
    var previousView: UIView?
    for v in views {
        if let pv = previousView {
            if let spv = v.superview {
                spv.addConstraint(item: v, attribute: attribute, toItem: pv)
            }
        }
        previousView = v
    }
}
