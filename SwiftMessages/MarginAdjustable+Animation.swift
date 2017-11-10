//
//  MarginAdjustable+Animation.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 11/5/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

public extension MarginAdjustable where Self: UIView {

    public func topAdjustment(container: UIView, context: AnimationContext) -> CGFloat {
        var top: CGFloat = 0
        top += bounceAnimationOffset
        if !context.safeZoneConflicts.isDisjoint(with: [.sensorNotch, .statusBar]) {
            if #available(iOS 11, *), container.safeAreaInsets.top > 0  {
                // Linear formula based on:
                // iPhone 8 - 20pt top safe area with 0pt adjustment
                // iPhone X - 44pt top safe area with -6pt adjustment
                top -= 6 * (container.safeAreaInsets.top - 20) / (44 - 20)
                top += safeAreaTopOffset
            } else {
                top += statusBarOffset
            }
        }
        if #available(iOS 11, *), !context.safeZoneConflicts.isDisjoint(with: .coveredStatusBar) {
            top -= safeAreaInsets.top
        }
        return top
    }

    public func bottomAdjustment(container: UIView, context: AnimationContext) -> CGFloat {
        var bottom: CGFloat = 0
        bottom += bounceAnimationOffset
        if !context.safeZoneConflicts.isDisjoint(with: [.homeIndicator]) {
            if #available(iOS 11, *), container.safeAreaInsets.bottom > 0  {
                bottom += safeAreaBottomOffset
            }
        }
        return bottom
    }
}
