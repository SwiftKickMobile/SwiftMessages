//
//  ViewControllerContainerView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/14/19.
//  Copyright © 2019 SwiftKick Mobile. All rights reserved.
//

import UIKit

class ViewControllerContainerView: CornerRoundingView {

    weak var viewController: UIViewController? {
        didSet {
            updateAdditionalSafeAreaInsets()
        }
    }

    open override func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            updateAdditionalSafeAreaInsets()
        }
    }

    /// Provides a workaround for the issue with view controller presentation,
    /// where the presented view controller's view has zero `safeAreaInsets`.
    /// I'm not sure if this is an iOS bug or if I'm doing something wrong (let me know!)
    /// but this workaround fixes the problem by applying `additionalSafeAreaInsets`
    /// to the presented view controller.
    private func updateAdditionalSafeAreaInsets() {
        guard let viewController = viewController else { return }
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets = viewController.additionalSafeAreaInsets + safeAreaInsets - viewController.view.safeAreaInsets
        }
    }
}
