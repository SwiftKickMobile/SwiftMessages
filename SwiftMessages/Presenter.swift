//
//  MessagePresenter.swift
//  SwiftMessages
//
//  Created by Tim Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

class Weak<T: AnyObject> {
    weak var value : T?
    init() {
        
    }
//    init (value: T) {
//        self.value = value
//    }
}

//class TypeErasing {
//    var value: Any
//    init (
//}

//enum Container {
//    case ViewController(viewController: Weak<UIViewController>)
//    case Window(viewController: WindowViewController)
//}

class Presenter<V: UIView>: Presentable {

    let configuration: Configuration<V>
    let view: V
    let maskingView = PassthroughView()
    let presentationContext = Weak<UIViewController>()
    var translationConstraint: NSLayoutConstraint! = nil
    
    init(configuration: Configuration<V>, view: V) {
        self.configuration = configuration
        self.view = view
        maskingView.clipsToBounds = true
    }
    
    var identity: String? {
        let identifiable = view as? Identifiable
        return identifiable?.identity
    }
    
    var pauseDuration: NSTimeInterval? {
        let duration: NSTimeInterval?
        switch self.configuration.duration {
        case .Automatic:
            duration = 2.0
        case .Seconds(let seconds):
            duration = seconds
        case .Forever:
            duration = nil
        }
        return duration
    }
    
    func show(completion completion: (completed: Bool) -> Void) throws {
        try presentationContext.value = getPresentationContext()
        configuration.viewConfigurations.forEach { $0(view: view) }
        install()
        showAnimation(completion: completion)
    }
    
    func getPresentationContext() throws -> UIViewController {
        
        func newWindowViewController(windowLevel: UIWindowLevel) -> UIViewController {
            let viewController = WindowViewController(windowLevel: windowLevel)
            viewController.statusBarStyle = configuration.preferredStatusBarStyle
            return viewController
        }
        
        switch configuration.presentationContext {
        case .Automatic:
            if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                return rootViewController.selectPresentationContextTopDown(configuration.presentationStyle)
            } else {
                throw Error.NoRootViewController
            }
        case .Window(let level):
            let viewController = WindowViewController(windowLevel: level)
            viewController.statusBarStyle = configuration.preferredStatusBarStyle
            return viewController
        case .ViewController(let viewController):
            return viewController.selectPresentationContextBottomUp(configuration.presentationStyle)
        }
    }
    
    func install() {
        guard let presentationContext = presentationContext.value else { return }
        if let windowViewController = presentationContext as? WindowViewController {
            windowViewController.install()
        }
        let containerView = presentationContext.view
        do {
            maskingView.translatesAutoresizingMaskIntoConstraints = false
            if let nav = presentationContext as? UINavigationController {
                containerView.insertSubview(maskingView, belowSubview: nav.navigationBar)
            } else if let tab = presentationContext as? UITabBarController {
                containerView.insertSubview(maskingView, belowSubview: tab.tabBar)
            } else {
                containerView.addSubview(maskingView)
            }
            let leading = NSLayoutConstraint(item: maskingView, attribute: .Leading, relatedBy: .Equal, toItem: containerView, attribute: .Leading, multiplier: 1.00, constant: 0.0)
            let trailing = NSLayoutConstraint(item: maskingView, attribute: .Trailing, relatedBy: .Equal, toItem: containerView, attribute: .Trailing, multiplier: 1.00, constant: 0.0)
            let top = topLayoutConstraint(view: maskingView, presentationContext: presentationContext)
            let bottom = bottomLayoutConstraint(view: maskingView, presentationContext: presentationContext)
            containerView.addConstraints([top, leading, bottom, trailing])
        }
        do {
            view.translatesAutoresizingMaskIntoConstraints = false
            maskingView.addSubview(view)
            let leading = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: maskingView, attribute: .Leading, multiplier: 1.00, constant: 0.0)
            let trailing = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: maskingView, attribute: .Trailing, multiplier: 1.00, constant: 0.0)
            switch configuration.presentationStyle {
            case .Top:
                translationConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: maskingView, attribute: .Top, multiplier: 1.00, constant: 0.0)
            case .Bottom:
                translationConstraint = NSLayoutConstraint(item: maskingView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.00, constant: 0.0)
            }
            maskingView.addConstraints([leading, trailing, translationConstraint])
            let size = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            translationConstraint.constant -= size.height
        }
        containerView.layoutIfNeeded()
    }
    
    func topLayoutConstraint(view view: UIView, presentationContext: UIViewController) -> NSLayoutConstraint {
        if case .Top = configuration.presentationStyle, let nav = presentationContext as? UINavigationController where nav.isVisible(view: nav.navigationBar) {
            return NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: nav.navigationBar, attribute: .Bottom, multiplier: 1.00, constant: 0.0)
        }
        return NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: presentationContext.view, attribute: .Top, multiplier: 1.00, constant: 0.0)
    }

    func bottomLayoutConstraint(view view: UIView, presentationContext: UIViewController) -> NSLayoutConstraint {
        if case .Bottom = configuration.presentationStyle, let tab = presentationContext as? UITabBarController where tab.isVisible(view: tab.tabBar) {
            return NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: tab.tabBar, attribute: .Top, multiplier: 1.00, constant: 0.0)
        }
        return NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: presentationContext.view, attribute: .Bottom, multiplier: 1.00, constant: 0.0)
    }

    func showAnimation(completion completion: (completed: Bool) -> Void) {
        switch configuration.presentationStyle {
        case .Top, .Bottom:
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.BeginFromCurrentState, .CurveLinear, .AllowUserInteraction], animations: {
                self.translationConstraint.constant = -5.0 // compensate for bounce overshoot
                self.view.superview?.layoutIfNeeded()
            }, completion: { completed in
                completion(completed: completed)
            })
        }
    }
    
    func hide(completion completion: (completed: Bool) -> Void) {
        switch configuration.presentationStyle {
        case .Top, .Bottom:
            UIView.animateWithDuration(0.25, delay: 0, options: [.BeginFromCurrentState, .CurveEaseIn], animations: {
                let size = self.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                self.translationConstraint.constant -= size.height
                self.view.superview?.layoutIfNeeded()
            }, completion: { completed in
                if let viewController = self.presentationContext.value as? WindowViewController {
                    viewController.uninstall()
                }
                self.maskingView.removeFromSuperview()
                completion(completed: completed)
            })
        }
    }
}
