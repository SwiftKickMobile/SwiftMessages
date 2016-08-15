//
//  UIViewController+Utils.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/5/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

private let fullScreenStyles: [UIModalPresentationStyle] = [.FullScreen, .OverFullScreen]

extension UIViewController {
    
    func sm_selectPresentationContextTopDown(presentationStyle: SwiftMessages.PresentationStyle) -> UIViewController {
        if let presented = sm_presentedFullScreenViewController() {
            return presented.sm_selectPresentationContextTopDown(presentationStyle)
        } else if case .Top = presentationStyle, let navigationController = sm_selectNavigationControllerTopDown() {
            return navigationController
        } else if case .Bottom = presentationStyle, let tabBarController = sm_selectTabBarControllerTopDown() {
            return tabBarController
        }
        return WindowViewController(windowLevel: self.view.window?.windowLevel ?? UIWindowLevelNormal)
    }
    
    private func sm_selectNavigationControllerTopDown() -> UINavigationController? {
        if let presented = sm_presentedFullScreenViewController() {
            return presented.sm_selectNavigationControllerTopDown()
        } else if let navigationController = self as? UINavigationController {
            if navigationController.sm_isVisible(view: navigationController.navigationBar) {
                return navigationController
            }
            return navigationController.topViewController?.sm_selectNavigationControllerTopDown()
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.sm_selectNavigationControllerTopDown()
        }
        return nil
    }

    private func sm_selectTabBarControllerTopDown() -> UITabBarController? {
        if let presented = sm_presentedFullScreenViewController() {
            return presented.sm_selectTabBarControllerTopDown()
        } else if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.sm_selectTabBarControllerTopDown()
        } else if let tabBarController = self as? UITabBarController {
            if tabBarController.sm_isVisible(view: tabBarController.tabBar) {
                return tabBarController
            }
            return tabBarController.selectedViewController?.sm_selectTabBarControllerTopDown()
        }
        return nil
    }
    
    private func sm_presentedFullScreenViewController() -> UIViewController? {
        if let presented = self.presentedViewController where fullScreenStyles.contains(presented.modalPresentationStyle) {
            return presented
        }
        return nil
    }

    func sm_selectPresentationContextBottomUp(presentationStyle: SwiftMessages.PresentationStyle) -> UIViewController {
        if let parent = parentViewController {
            if let navigationController = parent as? UINavigationController {
                if case .Top = presentationStyle where navigationController.sm_isVisible(view: navigationController.navigationBar) {
                    return navigationController
                }
                return navigationController.sm_selectPresentationContextBottomUp(presentationStyle)
            } else if let tabBarController = parent as? UITabBarController {
                if case .Bottom = presentationStyle where tabBarController.sm_isVisible(view: tabBarController.tabBar) {
                    return tabBarController
                }
                return tabBarController.sm_selectPresentationContextBottomUp(presentationStyle)
            }
        }
        if self.view is UITableView {
            // Never select scroll view as presentation context
            // because, you know, it scrolls.
            if let parent = self.parentViewController {
                return parent.sm_selectPresentationContextBottomUp(presentationStyle)
            } else {
                return WindowViewController(windowLevel: self.view.window?.windowLevel ?? UIWindowLevelNormal)
            }
        }
        return self
    }
    
    func sm_isVisible(view view: UIView) -> Bool {
        if view.hidden { return false }
        if view.alpha == 0.0 { return false }
        let frame = self.view.convertRect(view.bounds, fromView: view)
        if !CGRectIntersectsRect(self.view.bounds, frame) { return false }
        return true
    }
}
