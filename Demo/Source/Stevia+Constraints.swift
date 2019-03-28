//
//  Stevia+Constraints.swift
//  LoginNadir
//
//  Created by Sacha Durand Saint Omer on 01/10/15.
//  Copyright © 2015 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

// MARK: - Shortcut

public extension UIView {
    
    /**
     Helper for creating and adding NSLayoutConstraint but with default values provided.
     
     For instance
     
        addConstraint(item: view1, attribute: .CenterX, toItem: view2)
     
     is equivalent to
     
         addConstraint(
            NSLayoutConstraint(item: view1,
                attribute: .CenterX,
                 relatedBy: .Equal,
                 toItem: view2,
                 attribute: .CenterX,
                 multiplier: 1,
                 constant: 0
            )
         )
     
     - Returns: The NSLayoutConstraint created.
     */
    @discardableResult
    public func addConstraint(item view1: AnyObject,
                              attribute attr1: NSLayoutConstraint.Attribute,
                              relatedBy: NSLayoutConstraint.Relation = .equal,
                              toItem view2: AnyObject? = nil,
                              attribute attr2: NSLayoutConstraint.Attribute? = nil,
                              multiplier: CGFloat = 1,
                              constant: CGFloat = 0) -> NSLayoutConstraint {
        let c = constraint(
            item: view1, attribute: attr1,
            relatedBy: relatedBy,
            toItem: view2, attribute: attr2,
            multiplier: multiplier, constant: constant)
        addConstraint(c)
        return c
    }
}

/**
    Helper for creating a NSLayoutConstraint but with default values provided.
 
 For instance 
 
        constraint(item: view1, attribute: .CenterX, toItem: view2)
 
  is equivalent to
 
        NSLayoutConstraint(item: view1, attribute: .CenterX,
        relatedBy: .Equal,
        toItem: view2, attribute: .CenterX,
        multiplier: 1, constant: 0)
 
    - Returns: The NSLayoutConstraint created.
 */
public func constraint(item view1: AnyObject,
                       attribute attr1: NSLayoutConstraint.Attribute,
                       relatedBy: NSLayoutConstraint.Relation = .equal,
                       toItem view2: AnyObject? = nil,
                       attribute attr2: NSLayoutConstraint.Attribute? = nil, // Not an attribute??
                       multiplier: CGFloat = 1,
                       constant: CGFloat = 0) -> NSLayoutConstraint {
        let c =  NSLayoutConstraint(item: view1, attribute: attr1,
                                  relatedBy: relatedBy,
                                  toItem: view2, attribute: ((attr2 == nil) ? attr1 : attr2! ),
                                  multiplier: multiplier, constant: constant)
    c.priority = UILayoutPriority(rawValue: UILayoutPriority.defaultHigh.rawValue + 1)
    return c
}

public extension UIView {

/**
     Get User added constraints. For making complex changes on layout, we need to remove user added constraints.
     
     If we remove all constraints, it may return broken layout.
     
     Use this method as:
     
        removeConstraints(userAddedConstraints)
     
*/
    public var userAddedConstraints: [NSLayoutConstraint] {
        return constraints.filter { c in
            guard let cId = c.identifier else { return true }
            return !cId.contains("UIView-Encapsulated-Layout") && !cId.contains("Margin-guide-constraint")
        }
    }
}

// MARK: - Other

public extension UIView {

    /**
     Makes a view follow another view's frame.
     For instance if we want a button to be on top of an image :
     
     ```
     button.followEdges(image)
     ```
     */
    public func followEdges(_ otherView: UIView) {
        if let spv = superview {
            let cs = [
                constraint(item: self, attribute: .top, toItem: otherView),
                constraint(item: self, attribute: .right, toItem: otherView),
                constraint(item: self, attribute: .bottom, toItem: otherView),
                constraint(item: self, attribute: .left, toItem: otherView)
            ]
            spv.addConstraints(cs)
        }
    }
    
    /**
     Enforce a view to keep height and width equal at all times, essentially
     forcing it to be a square.
     
     ```
     image.heightEqualsWidth()
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func heightEqualsWidth() -> UIView {
        if let spv = superview {
            let c = constraint(item: self, attribute: .height, toItem: self, attribute: .width)
            spv.addConstraint(c)
        }
        return self
    }
    
}
