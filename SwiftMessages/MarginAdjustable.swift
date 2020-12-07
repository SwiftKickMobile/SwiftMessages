//
//  MarginAdjustable.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/5/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

/*
 Message views that implement the `MarginAdjustable` protocol will have their
 `layoutMargins` adjusted by SwiftMessages to account for the height of the
 status bar (when displayed under the status bar) and a small amount of
 overshoot in the bounce animation. `MessageView` implements this protocol
 by way of its parent class `BaseView`.
 
 For the effect of this protocol to work, subviews should be pinned to the
 message view's margins and the `layoutMargins` property should not be modified.
 
 This protocol is optional. A message view that doesn't implement `MarginAdjustable`
 is responsible for setting is own internal margins appropriately.
 */
public protocol MarginAdjustable {

    /// The amount to add to the safe area insets in calculating
    /// the layout margins.
    var layoutMarginAdditions: UIEdgeInsets { get }

    /// When `true`, SwiftMessages automatically collapses layout margin additions (topLayoutMarginAddition, etc.)
    /// when the default layout margins are greater than zero. This is typically used when a margin addition is only
    /// needed when the safe area inset is zero for a given edge. When the safe area inset for a given edge is non-zero,
    /// the additional margin is not added.
    var collapseLayoutMarginAdditions: Bool { get set }


    /// Start margins from the safe area.
    var respectSafeArea: Bool { get set }

    var bounceAnimationOffset: CGFloat { get set }
}

