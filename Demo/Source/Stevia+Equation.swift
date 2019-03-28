//
//  Stevia+Equation.swift
//  Stevia
//
//  Created by Sacha Durand Saint Omer on 21/01/2017.
//  Copyright © 2017 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

public struct SteviaAttribute {
    let view: UIView
    let attribute: NSLayoutConstraint.Attribute
    let constant: CGFloat?
    let multiplier: CGFloat?
    
    init(view: UIView, attribute: NSLayoutConstraint.Attribute) {
        self.view = view
        self.attribute = attribute
        self.constant = nil
        self.multiplier = nil
    }
    
    init(view: UIView, attribute: NSLayoutConstraint.Attribute, constant: CGFloat?, multiplier: CGFloat?) {
        self.view = view
        self.attribute = attribute
        self.constant = constant
        self.multiplier = multiplier
    }
}

public extension UIView {
    
    public var Width: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .width)
    }
    
    public var Height: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .height)
    }
    
    public var Top: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .top)
    }
    
    public var Bottom: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .bottom)
    }
    
    public var Left: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .left)
    }
    
    public var Right: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .right)
    }
    
    public var Leading: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .leading)
    }
    
    public var Trailing: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .trailing)
    }
    
    public var CenterX: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .centerX)
    }
    
    public var CenterY: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .centerY)
    }
    
    public var FirstBaseline: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .firstBaseline)
    }
    
    public var LastBaseline: SteviaAttribute {
        return SteviaAttribute(view: self, attribute: .lastBaseline)
    }
}

// MARK: - Equations of type v.P == v'.P' + X

@discardableResult
public func == (left: SteviaAttribute, right: SteviaAttribute) -> NSLayoutConstraint {
    let constant = right.constant ?? left.constant ?? 0
    let multiplier = right.multiplier ?? left.multiplier ?? 1

    if left.view.superview == right.view.superview { // A and B are at the same level
        // Old code
        if let spv = left.view.superview {
            return spv.addConstraint(item: left.view,
                                     attribute: left.attribute,
                                     toItem: right.view,
                                     attribute: right.attribute,
                                     multiplier: multiplier,
                                     constant: constant)
        }
    } else if left.view.superview == right.view { // A is in B (first level)
        return right.view.addConstraint(item: left.view,
                                        attribute: left.attribute,
                                        toItem: right.view,
                                        attribute: right.attribute,
                                        multiplier: multiplier,
                                        constant: constant)
    } else if right.view.superview == left.view { // B is in A (first level)
        return left.view.addConstraint(item: right.view,
                                       attribute: right.attribute,
                                       toItem: left.view,
                                       attribute: left.attribute,
                                       multiplier: multiplier,
                                       constant: constant)
    } else if left.view.isDescendant(of: right.view) { // A is in B (LOW level)
        return right.view.addConstraint(item: left.view,
                                        attribute: left.attribute,
                                        toItem: right.view,
                                        attribute: right.attribute,
                                        multiplier: multiplier,
                                        constant: constant)
    } else if right.view.isDescendant(of: left.view) { // B is in A (LOW level)
        return left.view.addConstraint(item: left.view,
                                       attribute: left.attribute,
                                       toItem: right.view,
                                       attribute: right.attribute,
                                       multiplier: multiplier,
                                       constant: constant)
    } else if let commonParent = commonParent(with: left.view, and: right.view) { // Look for common ancestor
        return commonParent.addConstraint(item: left.view,
                                          attribute: left.attribute,
                                          toItem: right.view,
                                          attribute: right.attribute,
                                          multiplier: multiplier,
                                          constant: constant)
    }
    
    return NSLayoutConstraint()
}

func commonParent(with viewA: UIView, and viewB: UIView) -> UIView? {
    
    // Both views should have a superview
    guard viewA.superview != nil && viewB.superview != nil else {
        return nil
    }
    
    // Find the common parent
    var spv = viewA.superview
    while spv != nil {
        if viewA.isDescendant(of: spv!) && viewB.isDescendant(of: spv!) {
            return spv
        } else {
            spv = spv?.superview
        }
    }
    return nil
}

@discardableResult
public func >= (left: SteviaAttribute, right: SteviaAttribute) -> NSLayoutConstraint {
    return applyRelation(left: left, right: right, relateBy: .greaterThanOrEqual)
}

@discardableResult
public func <= (left: SteviaAttribute, right: SteviaAttribute) -> NSLayoutConstraint {
    return applyRelation(left: left, right: right, relateBy: .lessThanOrEqual)
}

private func applyRelation(left: SteviaAttribute, right: SteviaAttribute, relateBy: NSLayoutConstraint.Relation) -> NSLayoutConstraint {
    let constant = right.constant ?? 0
    let multiplier = right.multiplier ?? 1
    if let spv = left.view.superview {
        return spv.addConstraint(item: left.view,
                                 attribute: left.attribute,
                                 relatedBy: relateBy,
                                 toItem: right.view,
                                 attribute: right.attribute,
                                 multiplier: multiplier,
                                 constant: constant)
    }
    return NSLayoutConstraint()
}

@discardableResult
public func + (left: SteviaAttribute, right: CGFloat) -> SteviaAttribute {
    return SteviaAttribute(view: left.view, attribute: left.attribute, constant: right, multiplier: left.multiplier)
}

@discardableResult
public func - (left: SteviaAttribute, right: CGFloat) -> SteviaAttribute {
    return SteviaAttribute(view: left.view, attribute: left.attribute, constant: -right, multiplier: left.multiplier)
}

@discardableResult
public func * (left: SteviaAttribute, right: CGFloat) -> SteviaAttribute {
    return SteviaAttribute(view: left.view, attribute: left.attribute, constant: left.constant, multiplier: right)
}

@discardableResult
public func / (left: SteviaAttribute, right: CGFloat) -> SteviaAttribute {
    return left * (1/right)
}

@discardableResult
public func % (left: CGFloat, right: SteviaAttribute) -> SteviaAttribute {
    return right * (left/100)
}

// MARK: - Equations of type v.P == X

@discardableResult
public func == (left: SteviaAttribute, right: CGFloat) -> NSLayoutConstraint {
    if let spv = left.view.superview {
        var toItem: UIView? = spv
        var constant: CGFloat = right
        if left.attribute == .width || left.attribute == .height {
            toItem = nil
        }
        if left.attribute == .bottom || left.attribute == .right {
            constant = -constant
        }
        return spv.addConstraint(item: left.view,
                                 attribute: left.attribute,
                                 toItem: toItem,
                                 constant: constant)
    }
    return NSLayoutConstraint()
}

@discardableResult
public func >= (left: SteviaAttribute, right: CGFloat) -> NSLayoutConstraint {
    if let spv = left.view.superview {
        return spv.addConstraint(item: left.view,
                                 attribute: left.attribute,
                                 relatedBy: .greaterThanOrEqual,
                                 toItem: spv,
                                 constant: right)
    }
    return NSLayoutConstraint()
}

@discardableResult
public func <= (left: SteviaAttribute, right: CGFloat) -> NSLayoutConstraint {
    if let spv = left.view.superview {
        return spv.addConstraint(item: left.view,
                                 attribute: left.attribute,
                                 relatedBy: .lessThanOrEqual,
                                 toItem: spv,
                                 constant: right)
    }
    return NSLayoutConstraint()
}
