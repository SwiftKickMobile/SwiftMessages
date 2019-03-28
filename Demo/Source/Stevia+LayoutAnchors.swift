//
//  Stevia+LayoutAnchors.swift
//  Stevia
//
//  Created by Sacha DSO on 09/10/2017.
//  Copyright © 2017 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
public struct SteviaLayoutYAxisAnchor {
    let anchor: NSLayoutYAxisAnchor
    let constant: CGFloat
    
    init(anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) {
        self.anchor = anchor
        self.constant = constant
    }
}

@available(iOS 9.0, *)
public struct SteviaLayoutXAxisAnchor {
    let anchor: NSLayoutXAxisAnchor
    let constant: CGFloat
    
    init(anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) {
        self.anchor = anchor
        self.constant = constant
    }
}

@available(iOS 9.0, *)
public extension UILayoutGuide {

    public var Top: SteviaLayoutYAxisAnchor {
        return SteviaLayoutYAxisAnchor(anchor: topAnchor)
    }

    public var Bottom: SteviaLayoutYAxisAnchor {
        return SteviaLayoutYAxisAnchor(anchor: bottomAnchor)
    }
    
    public var Left: SteviaLayoutXAxisAnchor {
        return SteviaLayoutXAxisAnchor(anchor: leftAnchor)
    }
    
    public var Right: SteviaLayoutXAxisAnchor {
        return SteviaLayoutXAxisAnchor(anchor: rightAnchor)
    }
    
    public var Leading: SteviaLayoutXAxisAnchor {
        return SteviaLayoutXAxisAnchor(anchor: leadingAnchor)
    }
    
    public var Trailing: SteviaLayoutXAxisAnchor {
        return SteviaLayoutXAxisAnchor(anchor: trailingAnchor)
    }

    public var CenterX: SteviaLayoutXAxisAnchor {
        return SteviaLayoutXAxisAnchor(anchor: centerXAnchor)
    }
    
    public var CenterY: SteviaLayoutYAxisAnchor {
        return SteviaLayoutYAxisAnchor(anchor: centerYAnchor)
    }
}

@available(iOS 9.0, *)
@discardableResult
public func == (left: SteviaAttribute, right: SteviaLayoutYAxisAnchor) -> NSLayoutConstraint {
    
    var constraint = NSLayoutConstraint()
    
    if left.attribute == .top {
        constraint = left.view.topAnchor.constraint(equalTo: right.anchor, constant: right.constant)
    }
    
    if left.attribute == .bottom {
        constraint = left.view.bottomAnchor.constraint(equalTo: right.anchor, constant: right.constant)
    }
    
    constraint.isActive = true
    return constraint
}

@available(iOS 9.0, *)
@discardableResult
public func == (left: SteviaAttribute, right: SteviaLayoutXAxisAnchor) -> NSLayoutConstraint {
    
    var constraint = NSLayoutConstraint()
    
    if left.attribute == .left {
        constraint = left.view.leftAnchor.constraint(equalTo: right.anchor, constant: right.constant)
    }
    
    if left.attribute == .right {
        constraint = left.view.rightAnchor.constraint(equalTo: right.anchor, constant: right.constant)
    }
    
    if left.attribute == .leading {
        constraint = left.view.leadingAnchor.constraint(equalTo: right.anchor, constant: right.constant)
    }
    
    if left.attribute == .trailing {
        constraint = left.view.trailingAnchor.constraint(equalTo: right.anchor, constant: right.constant)
    }
    
    constraint.isActive = true
    return constraint
}

// SteviaLayoutYAxisAnchor

@available(iOS 9.0, *)
@discardableResult
public func + (left: SteviaLayoutYAxisAnchor, right: CGFloat) -> SteviaLayoutYAxisAnchor {
    return SteviaLayoutYAxisAnchor(anchor: left.anchor, constant: right)
}

@available(iOS 9.0, *)
@discardableResult
public func - (left: SteviaLayoutYAxisAnchor, right: CGFloat) -> SteviaLayoutYAxisAnchor {
    return SteviaLayoutYAxisAnchor(anchor: left.anchor, constant: -right)
}

@available(iOS 9.0, *)
@discardableResult
public func + (left: SteviaLayoutXAxisAnchor, right: CGFloat) -> SteviaLayoutXAxisAnchor {
    return SteviaLayoutXAxisAnchor(anchor: left.anchor, constant: right)
}

@available(iOS 9.0, *)
@discardableResult
public func - (left: SteviaLayoutXAxisAnchor, right: CGFloat) -> SteviaLayoutXAxisAnchor {
    return SteviaLayoutXAxisAnchor(anchor: left.anchor, constant: -right)
}

// UILayoutSupport

@available(iOS 9.0, *)
public extension UILayoutSupport {
    
    public var Top: SteviaLayoutYAxisAnchor {
        return SteviaLayoutYAxisAnchor(anchor: topAnchor)
    }
    
    public var Bottom: SteviaLayoutYAxisAnchor {
        return SteviaLayoutYAxisAnchor(anchor: bottomAnchor)
    }
}
