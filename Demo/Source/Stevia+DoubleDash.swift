//
//  Stevia+DoubleDash.swift
//  Stevia
//
//  Created by Sacha Durand Saint Omer on 03/05/16.
//  Copyright © 2016 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

infix operator -- :AdditionPrecedence

@discardableResult
public func -- (left: UIView, right: CGFloat) -> PartialConstraint {
    return left-right
}

@discardableResult
public func -- (left: SideConstraint, right: UIView) -> UIView {
    return left-right
}

@discardableResult
public func -- (left: [UIView], right: SideConstraint) -> [UIView] {
    return left-right
}

@discardableResult
public func -- (left: UIView, right: SideConstraint) -> UIView {
    return left-right
}

@discardableResult
public func -- (left: PartialConstraint, right: UIView) -> [UIView] {
    return left-right
}

@discardableResult
public func -- (left: UIView, right: UIView) -> [UIView] {
    return left-right
}

@discardableResult
public func -- (left: [UIView], right: CGFloat) -> PartialConstraint {
    return left-right
}

@discardableResult
public func -- (left: [UIView], right: UIView) -> [UIView] {
    return left-right
}

@discardableResult
public func -- (left: UIView, right: String) -> Space {
    return left-right
}

@discardableResult
public func -- (left: [UIView], right: String) -> Space {
    return left-right
}

@discardableResult
public func -- (left: Space, right: UIView) -> [UIView] {
    return left-right
}

@discardableResult
public func -- (left: UIView,
                right: SteviaFlexibleMargin) -> PartialFlexibleConstraint {
    return left-right
}

@discardableResult
public func -- (left: [UIView],
                right: SteviaFlexibleMargin) -> PartialFlexibleConstraint {
    return left-right
}

@discardableResult
public func -- (left: PartialFlexibleConstraint, right: UIView) -> [UIView] {
    return left-right
}

@discardableResult
public func -- (left: SteviaLeftFlexibleMargin, right: UIView) -> UIView {
    return left-right
}

@discardableResult
public func -- (left: UIView, right: SteviaRightFlexibleMargin) -> UIView {
    return left-right
}

@discardableResult
public func -- (left: [UIView], right: SteviaRightFlexibleMargin) -> [UIView] {
    return left-right
}
