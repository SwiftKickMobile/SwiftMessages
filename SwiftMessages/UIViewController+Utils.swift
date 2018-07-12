//
//  UIViewController+Utils.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/5/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

private let fullScreenStyles: [UIModalPresentationStyle] = [.fullScreen, .overFullScreen]

extension UIViewController {
    
    func sm_selectPresentationContextTopDown(_ config: SwiftMessages.Config) -> UIViewController {
        let topBottomStyle = config.presentationStyle.topBottomStyle
        if let presented = sm_presentedFullScreenViewController() {
            return presented.sm_selectPresentationContextTopDown(config)
        } else if case .top? = topBottomStyle, let navigationController = sm_selectNavigationControllerTopDown() {
            return navigationController
        } else if case .bottom? = topBottomStyle, let tabBarController = sm_selectTabBarControllerTopDown() {
            return tabBarController
        }
        return WindowViewController.newInstance(windowLevel: self.view.window?.windowLevel, config: config)
    }
    
    fileprivate func sm_selectNavigationControllerTopDown() -> UINavigationController? {
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

    fileprivate func sm_selectTabBarControllerTopDown() -> UITabBarController? {
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
    
    fileprivate func sm_presentedFullScreenViewController() -> UIViewController? {
        if let presented = self.presentedViewController, fullScreenStyles.contains(presented.modalPresentationStyle) {
            return presented
        }
        return nil
    }

    func sm_selectPresentationContextBottomUp(_ config: SwiftMessages.Config) -> UIViewController {
        let topBottomStyle = config.presentationStyle.topBottomStyle
        if let parent = parent {
            if let navigationController = parent as? UINavigationController {
                if case .top? = topBottomStyle, navigationController.sm_isVisible(view: navigationController.navigationBar) {
                    return navigationController
                }
                return navigationController.sm_selectPresentationContextBottomUp(config)
            } else if let tabBarController = parent as? UITabBarController {
                if case .bottom? = topBottomStyle, tabBarController.sm_isVisible(view: tabBarController.tabBar) {
                    return tabBarController
                }
                return tabBarController.sm_selectPresentationContextBottomUp(config)
            }
        }
        if self.view is UITableView {
            // Never select scroll view as presentation context
            // because, you know, it scrolls.
            if let parent = self.parent {
                return parent.sm_selectPresentationContextBottomUp(config)
            } else {
                return WindowViewController.newInstance(windowLevel: self.view.window?.windowLevel, config: config)
            }
        }
        return self
    }
    
    func sm_isVisible(view: UIView) -> Bool {
        if view.isHidden { return false }
        if view.alpha == 0.0 { return false }
        let frame = self.view.convert(view.bounds, from: view)
        if !self.view.bounds.intersects(frame) { return false }
        return true
    }
}

extension SwiftMessages.PresentationStyle {
    /// A temporary workaround to allow custom presentation contexts using `TopBottomAnimation`
    /// to display properly behind bars. THe long term solution is to refactor all of the
    /// presentation context logic to work with safe area insets.
    var topBottomStyle: TopBottomAnimation.Style? {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .custom(let animator): return (animator as? TopBottomAnimation)?.style
        case .center: return nil
        }
    }
}
