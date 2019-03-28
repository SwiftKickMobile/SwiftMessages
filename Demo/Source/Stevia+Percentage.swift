//
//  Stevia+Percentage.swift
//  Stevia
//
//  Created by Sacha Durand Saint Omer on 21/01/2017.
//  Copyright © 2017 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

public struct SteviaPercentage {
    let value: CGFloat
}

postfix operator %
public postfix func % (v: CGFloat) -> SteviaPercentage {
    return SteviaPercentage(value: v)
}

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
    public func size(_ p: SteviaPercentage) -> UIView {
        width(p)
        height(p)
        return self
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
    public func width(_ p: SteviaPercentage) -> UIView {
        if let spv = superview {
            Width == p.value % spv.Width
        }
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
    public func height(_ p: SteviaPercentage) -> UIView {
        if let spv = superview {
            Height == p.value % spv.Height
        }
        return self
    }
    
    /** Sets the top margin for a view.
     
    Example Usage :
     
     label.top(20)
     label.top(<=20)
     label.top(>=20)
     label.top(20%)
     
    - Returns: Itself for chaining purposes
     */
    @discardableResult
    public func top(_ p: SteviaPercentage) -> UIView {
        if let spv = superview {
            Top == p.value % spv.Bottom
        }
        return self
    }
    
    /** Sets the left margin for a view.
     
     Example Usage :
     
     label.left(20)
     label.left(<=20)
     label.left(>=20)
     label.left(20%)
     
     - Returns: Itself for chaining purposes
     */
    @discardableResult
    public func left(_ p: SteviaPercentage) -> UIView {
        if let spv = superview {
            Left == p.value % spv.Right
        }
        return self
    }
    
    /** Sets the right margin for a view.
     
     Example Usage :
     
     label.right(20)
     label.right(<=20)
     label.right(>=20)
     label.right(20%)
     
     - Returns: Itself for chaining purposes
     */
    @discardableResult
    public func right(_ p: SteviaPercentage) -> UIView {
        if let spv = superview {
            if p.value == 100 {
                Right == spv.Left
            } else {
                Right == (100 - p.value) % spv.Right
            }
        }
        return self
    }
    
    /** Sets the bottom margin for a view.
     
     Example Usage :
     
     label.bottom(20)
     label.bottom(<=20)
     label.bottom(>=20)
     label.bottom(20%)
     
     - Returns: Itself for chaining purposes
     */
    @discardableResult
    public func bottom(_ p: SteviaPercentage) -> UIView {
        if let spv = superview {
            if p.value == 100 {
                Bottom == spv.Top
            } else {
                Bottom == (100 - p.value) % spv.Bottom
            }
        }
        return self
    }
}
