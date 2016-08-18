//
//  BackgroundViewable.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/15/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

/**
 Message views that implement the `BackgroundViewable` protocol will have the
 pan-to-hide gesture recognizer installed in the `backgroundView`. Message views
 always span the full width of the containing view. Typically, the `backgroundView`
 property defines the message view's visible region, allowing for card-style views
 where the message view background is transparent and the background view is inset
 from by some amount. See CardView.nib, for example.
 
 This protocol is optional. Message views that don't implement `BackgroundViewable`
 will have the pan-to-hide gesture installed in the message view itself.
 */
public protocol BackgroundViewable {
    var backgroundView: UIView! { get }
}