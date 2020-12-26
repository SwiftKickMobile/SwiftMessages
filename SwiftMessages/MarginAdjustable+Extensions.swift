//
//  MarginAdjustable+Extensions.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 11/5/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

extension MarginAdjustable where Self: UIView {
    public func defaultMarginAdjustment(context: AnimationContext) -> UIEdgeInsets {
        var layoutMargins: UIEdgeInsets = layoutMarginAdditions
        var safeAreaInsets: UIEdgeInsets = {
            guard respectSafeArea else { return .zero }
            if #available(iOS 11, *) {
                insetsLayoutMarginsFromSafeArea = false
                return self.safeAreaInsets
            } else {
                #if SWIFTMESSAGES_APP_EXTENSIONS
                let application: UIApplication? = nil
                #else
                let application: UIApplication? = UIApplication.shared
                #endif
                if !context.safeZoneConflicts.isDisjoint(with: [.statusBar]),
                   let app = application,
                   app.statusBarOrientation == .portrait || app.statusBarOrientation == .portraitUpsideDown {
                    let frameInWindow = convert(bounds, to: window)
                    let top = max(0, 20 - frameInWindow.minY)
                    return UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
                } else {
                    return .zero
                }
            }
        }()
        if !context.safeZoneConflicts.isDisjoint(with: .overStatusBar) {
            safeAreaInsets.top = 0
        }
        layoutMargins = collapseLayoutMarginAdditions
            ? layoutMargins.collapse(toInsets: safeAreaInsets)
            : layoutMargins + safeAreaInsets
        return layoutMargins
    }
}

extension UIEdgeInsets {
    func collapse(toInsets insets: UIEdgeInsets) -> UIEdgeInsets {
        let top = self.top.collapse(toInset: insets.top)
        let left = self.left.collapse(toInset: insets.left)
        let bottom = self.bottom.collapse(toInset: insets.bottom)
        let right = self.right.collapse(toInset: insets.right)
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

extension CGFloat {
    func collapse(toInset inset: CGFloat) -> CGFloat {
        return Swift.max(self, inset)
    }
}
