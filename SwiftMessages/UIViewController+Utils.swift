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
    
    func selectPresentationContextTopDown(presentationStyle: SwiftMessages.PresentationStyle) -> UIViewController {
        if let presented = presentedFullScreenViewController() {
            return presented.selectPresentationContextTopDown(presentationStyle)
        } else if case .Top = presentationStyle, let navigationController = selectNavigationControllerTopDown() {
            return navigationController
        } else if case .Bottom = presentationStyle, let tabBarController = selectTabBarControllerTopDown() {
            return tabBarController
        }
        return WindowViewController(windowLevel: self.view.window?.windowLevel ?? UIWindowLevelNormal)
    }
    
    private func selectNavigationControllerTopDown() -> UINavigationController? {
        if let presented = presentedFullScreenViewController() {
            return presented.selectNavigationControllerTopDown()
        } else if let navigationController = self as? UINavigationController {
            if navigationController.isVisible(view: navigationController.navigationBar) {
                return navigationController
            }
            return navigationController.topViewController?.selectNavigationControllerTopDown()
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.selectNavigationControllerTopDown()
        }
        return nil
    }

    private func selectTabBarControllerTopDown() -> UITabBarController? {
        if let presented = presentedFullScreenViewController() {
            return presented.selectTabBarControllerTopDown()
        } else if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.selectTabBarControllerTopDown()
        } else if let tabBarController = self as? UITabBarController {
            if tabBarController.isVisible(view: tabBarController.tabBar) {
                return tabBarController
            }
            return tabBarController.selectedViewController?.selectTabBarControllerTopDown()
        }
        return nil
    }
    
    private func presentedFullScreenViewController() -> UIViewController? {
        if let presented = self.presentedViewController where fullScreenStyles.contains(presented.modalPresentationStyle) {
            return presented
        }
        return nil
    }

    func selectPresentationContextBottomUp(presentationStyle: SwiftMessages.PresentationStyle) -> UIViewController {
        if let parent = parentViewController {
            if let navigationController = parent as? UINavigationController {
                if case .Top = presentationStyle where navigationController.isVisible(view: navigationController.navigationBar) {
                    return navigationController
                }
                return navigationController.selectPresentationContextBottomUp(presentationStyle)
            } else if let tabBarController = parent as? UITabBarController {
                if case .Bottom = presentationStyle where tabBarController.isVisible(view: tabBarController.tabBar) {
                    return tabBarController
                }
                return tabBarController.selectPresentationContextBottomUp(presentationStyle)
            }
        }
        if self.view is UITableView {
            // Never select scroll view as presentation context
            // because, you know, it scrolls.
            if let parent = self.parentViewController {
                return parent.selectPresentationContextBottomUp(presentationStyle)
            } else {
                return WindowViewController(windowLevel: self.view.window?.windowLevel ?? UIWindowLevelNormal)
            }
        }
        return self
    }
    
    func isVisible(view view: UIView) -> Bool {
        if view.hidden { return false }
        if view.alpha == 0.0 { return false }
        let frame = self.view.convertRect(view.bounds, fromView: view)
        if !CGRectIntersectsRect(self.view.bounds, frame) { return false }
        return true
    }
}
