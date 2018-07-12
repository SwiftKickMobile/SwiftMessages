//
//  MarginAdjustable+Animation.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 11/5/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

public extension MarginAdjustable where Self: UIView {

    public func defaultMarginAdjustment(context: AnimationContext) -> UIEdgeInsets {
        return UIEdgeInsets(top: topAdjustment(context: context), left: 0, bottom: bottomAdjustment(context: context), right: 0)
    }

    private func topAdjustment(context: AnimationContext) -> CGFloat {        
        var top: CGFloat = 0
        if !context.safeZoneConflicts.isDisjoint(with: [.sensorNotch, .statusBar]) {
            #if SWIFTMESSAGES_APP_EXTENSIONS
            let application: UIApplication? = nil
            #else
            let application: UIApplication? = UIApplication.shared
            #endif
            if #available(iOS 11, *)  {
                do {
                    // To accommodate future safe areas, using a linear formula based on
                    // two data points:
                    // iPhone 8 - 20pt top safe area needs 0pt adjustment
                    // iPhone X - 44pt top safe area needs -6pt adjustment
                    top -= 6 * (safeAreaInsets.top - 20) / (44 - 20)
                }
                top += safeAreaTopOffset
            } else if let app = application, app.statusBarOrientation == .portrait || app.statusBarOrientation == .portraitUpsideDown {
                let frameInWindow = convert(bounds, to: window)
                if frameInWindow.minY == 0 {
                    top += statusBarOffset
                }
            }
        } else if #available(iOS 11, *), !context.safeZoneConflicts.isDisjoint(with: .overStatusBar) {
            top -= safeAreaInsets.top
        }
        return top
    }

    private func bottomAdjustment(context: AnimationContext) -> CGFloat {
        var bottom: CGFloat = 0
        if !context.safeZoneConflicts.isDisjoint(with: [.homeIndicator]) {
            if #available(iOS 11, *), safeAreaInsets.bottom > 0  {
                do {
                    // This adjustment was added to fix a layout issue with iPhone X in
                    // landscape mode. Using a linear formula based on two data points to help
                    // future proof against future safe areas:
                    // iPhone X portrait: 34pt bottom safe area needs 0pt adjustment
                    // iPhone X landscape: 21pt bottom safe area needs 12pt adjustment
                    bottom -= 12 * (safeAreaInsets.bottom - 34) / (34 - 21)
                }
                bottom += safeAreaBottomOffset
            }
        }
        return bottom
    }
}
