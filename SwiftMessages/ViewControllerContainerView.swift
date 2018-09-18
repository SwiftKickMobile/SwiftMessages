//
//  ViewControllerContainerView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/4/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit

/// A subclass of `CornerRoundingView` intended as the container view
/// of a view controller's view. It's job is to respect the view controller's
/// `preferredContentSize.height` property. (SwiftMessages does not currently
/// consider the value of `preferredContentSize.width`, but this may change in the future).
open class ViewControllerContainerView: CornerRoundingView {

    open internal(set) weak var viewController: UIViewController?

    open override var intrinsicContentSize: CGSize {
        if let preferredHeight = viewController?.preferredContentSize.height,
            preferredHeight > 0 {
            return CGSize(width: UIView.noIntrinsicMetric, height: preferredHeight)
        }
        return super.intrinsicContentSize
    }
}
