//
//  Stevia+FlexibleMargin.swift
//  Stevia
//
//  Created by Sacha Durand Saint Omer on 10/07/16.
//  Copyright © 2016 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

prefix operator >=
@discardableResult
public prefix func >= (p: CGFloat) -> SteviaFlexibleMargin {
    return SteviaFlexibleMargin(points: p, relation: .greaterThanOrEqual)
}

prefix operator <=
@discardableResult
public prefix func <= (p: CGFloat) -> SteviaFlexibleMargin {
    return SteviaFlexibleMargin(points: p, relation: .lessThanOrEqual)
}

public struct SteviaFlexibleMargin {
    var points: CGFloat!
    var relation: NSLayoutConstraint.Relation!
}

public struct PartialFlexibleConstraint {
    var fm: SteviaFlexibleMargin!
    var view1: UIView?
    var views: [UIView]?
}

@discardableResult
public func - (left: UIView,
               right: SteviaFlexibleMargin) -> PartialFlexibleConstraint {
    return PartialFlexibleConstraint(fm: right, view1: left, views: nil)
}

@discardableResult
public func - (left: [UIView],
               right: SteviaFlexibleMargin) -> PartialFlexibleConstraint {
    return PartialFlexibleConstraint(fm: right, view1: nil, views: left)
}

@discardableResult
public func - (left: PartialFlexibleConstraint, right: UIView) -> [UIView] {
    if let views = left.views {
        if let spv = right.superview {
            let c = constraint(item: right, attribute: .left,
                               relatedBy: left.fm.relation, toItem: views.last,
                               attribute: .right,
                               constant: left.fm.points)
            spv.addConstraint(c)
        }
        return views + [right]
    } else {
        if let spv = right.superview {
            let c = constraint(item: right, attribute: .left,
                               relatedBy: left.fm.relation, toItem: left.view1!,
                               attribute: .right,
                               constant: left.fm.points)
            spv.addConstraint(c)
        }
        return [left.view1!, right]
    }
}

// Left Flexible margin

public struct SteviaLeftFlexibleMargin {
    let fm: SteviaFlexibleMargin
}

@discardableResult
public prefix func |- (fm: SteviaFlexibleMargin) -> SteviaLeftFlexibleMargin {
    return SteviaLeftFlexibleMargin(fm: fm)
}

@discardableResult
public func - (left: SteviaLeftFlexibleMargin, right: UIView) -> UIView {
    if let spv = right.superview {
        let c = constraint(item: right, attribute: .left,
                           relatedBy: left.fm.relation, toItem: spv,
                           attribute: .left,
                           constant: left.fm.points)
        spv.addConstraint(c)
    }
    return right
}

// Right Flexible margin

public struct SteviaRightFlexibleMargin {
    let fm: SteviaFlexibleMargin
}

@discardableResult
public postfix func -| (fm: SteviaFlexibleMargin) -> SteviaRightFlexibleMargin {
    return SteviaRightFlexibleMargin(fm: fm)
}

@discardableResult
public func - (left: UIView, right: SteviaRightFlexibleMargin) -> UIView {
    if let spv = left.superview {
        let c = constraint(item: spv, attribute: .right,
                           relatedBy: right.fm.relation, toItem: left,
                           attribute: .right,
                           constant: right.fm.points)
        spv.addConstraint(c)
    }
    return left
}

@discardableResult
public func - (left: [UIView], right: SteviaRightFlexibleMargin) -> [UIView] {
    if let spv = left.last!.superview {
        let c = constraint(item: spv, attribute: .right,
                           relatedBy: right.fm.relation,
                           toItem: left.last!,
                           attribute: .right,
                           constant: right.fm.points)
        spv.addConstraint(c)
    }
    return left
}
