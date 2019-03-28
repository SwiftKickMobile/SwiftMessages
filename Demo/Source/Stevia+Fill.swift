//
//  Stevia+Fill.swift
//  Stevia
//
//  Created by Sacha Durand Saint Omer on 10/02/16.
//  Copyright © 2016 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

public extension UIView {
    
    /**
     Adds the constraints needed for the view to fill its `superview`.
     A padding can be used to apply equal spaces between the view and its superview
    */
    @discardableResult
    public func fillContainer(_ padding: CGFloat = 0) -> UIView {
        fillHorizontally(m: padding)
        fillVertically(m: padding)
        return self
    }
    
    @available(*, deprecated: 2.2.1, message: "Use 'fillVertically' instead")
    /**
     Adds the constraints needed for the view to fill its `superview` Vertically.
     A padding can be used to apply equal spaces between the view and its superview
     */
    public func fillV(m points: CGFloat = 0) -> UIView {
        return fill(.vertical, points: points)
    }
    
    /**
     Adds the constraints needed for the view to fill its `superview` Vertically.
     A padding can be used to apply equal spaces between the view and its superview
     */
    @discardableResult
    public func fillVertically(m points: CGFloat = 0) -> UIView {
        return fill(.vertical, points: points)
    }
    
    @available(*, deprecated: 2.2.1, message: "Use 'fillHorizontally' instead")
    /**
     Adds the constraints needed for the view to fill its `superview` Horizontally.
     A padding can be used to apply equal spaces between the view and its superview
     */
    public func fillH(m points: CGFloat = 0) -> UIView {
        return fill(.horizontal, points: points)
    }
    
    /**
     Adds the constraints needed for the view to fill its `superview` Horizontally.
     A padding can be used to apply equal spaces between the view and its superview
     */
    @discardableResult
    public func fillHorizontally(m points: CGFloat = 0) -> UIView {
        return fill(.horizontal, points: points)
    }
    
    fileprivate func fill(_ axis: NSLayoutConstraint.Axis, points: CGFloat = 0) -> UIView {
        let a: NSLayoutConstraint.Attribute = axis == .vertical ? .top : .left
        let b: NSLayoutConstraint.Attribute = axis == .vertical ? .bottom : .right
        if let spv = superview {
            let c1 = constraint(item: self, attribute: a, toItem: spv, constant: points)
            let c2 = constraint(item: self, attribute: b, toItem: spv, constant: -points)
            spv.addConstraints([c1, c2])
        }
        return self
    }
}
