//
//  MessagePresenter.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

class Weak<T: AnyObject> {
    weak var value : T?
    init() {}
}

protocol PresenterDelegate: class {
    func hide(presenter presenter: Presenter)
    func panStarted(presenter presenter: Presenter)
    func panEnded(presenter presenter: Presenter)
}

class Presenter: NSObject, UIGestureRecognizerDelegate {

    let config: SwiftMessages.Config
    let view: UIView
    weak var delegate: PresenterDelegate?
    let maskingView = PassthroughView()
    let presentationContext = Weak<UIViewController>()
    let panRecognizer: UIPanGestureRecognizer
    var translationConstraint: NSLayoutConstraint! = nil
    
    init(config: SwiftMessages.Config, view: UIView, delegate: PresenterDelegate) {
        self.config = config
        self.view = view
        self.delegate = delegate
        panRecognizer = UIPanGestureRecognizer()
        super.init()
        panRecognizer.addTarget(self, action: #selector(Presenter.pan(_:)))
        panRecognizer.delegate = self
        maskingView.clipsToBounds = true
    }
    
    var id: String? {
        let identifiable = view as? Identifiable
        return identifiable?.id
    }
    
    var pauseDuration: NSTimeInterval? {
        let duration: NSTimeInterval?
        switch self.config.duration {
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
        install()
        showAnimation(completion: completion)
    }
    
    func getPresentationContext() throws -> UIViewController {
        
        func newWindowViewController(windowLevel: UIWindowLevel) -> UIViewController {
            let viewController = WindowViewController(windowLevel: windowLevel)
            if windowLevel == UIWindowLevelNormal {
                viewController.statusBarStyle = config.preferredStatusBarStyle
            }
            return viewController
        }
        
        switch config.presentationContext {
        case .Automatic:
            if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                return rootViewController.sm_selectPresentationContextTopDown(config.presentationStyle)
            } else {
                throw Error.NoRootViewController
            }
        case .Window(let level):
            return newWindowViewController(level)
        case .ViewController(let viewController):
            return viewController.sm_selectPresentationContextBottomUp(config.presentationStyle)
        }
    }
    
    /*
     MARK: - Installation
     */
    
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
            switch config.presentationStyle {
            case .Top:
                translationConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: maskingView, attribute: .Top, multiplier: 1.00, constant: 0.0)
            case .Bottom:
                translationConstraint = NSLayoutConstraint(item: maskingView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.00, constant: 0.0)
            }
            maskingView.addConstraints([leading, trailing, translationConstraint])
            if let adjustable = view as? MarginAdjustable {
                var top: CGFloat = 0.0
                var bottom: CGFloat = 0.0
                switch config.presentationStyle {
                case .Top:
                    top += adjustable.bounceAnimationOffset
                    if !UIApplication.sharedApplication().statusBarHidden {
                        if let vc = presentationContext as? WindowViewController {
                            if vc.windowLevel == UIWindowLevelNormal {
                                top += adjustable.statusBarOffset
                            }
                        } else if let vc = presentationContext as? UINavigationController {
                            if !vc.sm_isVisible(view: vc.navigationBar) {
                                top += adjustable.statusBarOffset
                            }
                        } else {
                            top += adjustable.statusBarOffset
                        }
                    }
                case .Bottom:
                    bottom += adjustable.bounceAnimationOffset
                }
                view.layoutMargins = UIEdgeInsets(top: top, left: 0.0, bottom: bottom, right: 0.0)
            }
            let size = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            translationConstraint.constant -= size.height
        }
        containerView.layoutIfNeeded()
        if config.interactiveHide {
            view.addGestureRecognizer(panRecognizer)
        }
        do {
            
            func setupInteractive(interactive: Bool) {
                if interactive {
                    maskingView.tappedHander = { [weak self] in
                        guard let strongSelf = self else { return }
                        self?.delegate?.hide(presenter: strongSelf)
                    }
                } else {
                    // There's no action to take, but the presence of
                    // a tap handler prevents interaction with underlying views.
                    maskingView.tappedHander = { }
                }
            }
            
            switch config.dimMode {
            case .None:
                break
            case .Gray(let interactive):
                setupInteractive(interactive)
            case .Color(_, let interactive):
                setupInteractive(interactive)
            }
        }
    }
    
    func topLayoutConstraint(view view: UIView, presentationContext: UIViewController) -> NSLayoutConstraint {
        if case .Top = config.presentationStyle, let nav = presentationContext as? UINavigationController where nav.sm_isVisible(view: nav.navigationBar) {
            return NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: nav.navigationBar, attribute: .Bottom, multiplier: 1.00, constant: 0.0)
        }
        return NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: presentationContext.view, attribute: .Top, multiplier: 1.00, constant: 0.0)
    }

    func bottomLayoutConstraint(view view: UIView, presentationContext: UIViewController) -> NSLayoutConstraint {
        if case .Bottom = config.presentationStyle, let tab = presentationContext as? UITabBarController where tab.sm_isVisible(view: tab.tabBar) {
            return NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: tab.tabBar, attribute: .Top, multiplier: 1.00, constant: 0.0)
        }
        return NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: presentationContext.view, attribute: .Bottom, multiplier: 1.00, constant: 0.0)
    }
    
    /*
     MARK: - Showing and hiding
     */

    func showAnimation(completion completion: (completed: Bool) -> Void) {

        showViewAnimation(completion: completion)
        
        func dim(color: UIColor) {
            self.maskingView.backgroundColor = UIColor.clearColor()
            UIView.animateWithDuration(0.2, animations: {
                self.maskingView.backgroundColor = color
            })
        }

        switch config.dimMode {
        case .None:
            break
        case .Gray:
            dim(UIColor(white: 0, alpha: 0.3))
        case .Color(let color, _):
            dim(color)
        }
    }

    func showViewAnimation(completion completion: (completed: Bool) -> Void) {
        
        switch config.presentationStyle {
        case .Top, .Bottom:
            let animationDistance = self.translationConstraint.constant + bounceOffset
            // Cap the initial velocity at zero because the bounceOffset may not be great
            // enough to allow for greater bounce induced by a quick panning motion.
            let initialSpringVelocity = animationDistance == 0.0 ? 0.0 : min(0.0, closeSpeed / animationDistance)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: initialSpringVelocity, options: [.BeginFromCurrentState, .CurveLinear, .AllowUserInteraction], animations: {
                self.translationConstraint.constant = -self.bounceOffset
                self.view.superview?.layoutIfNeeded()
                }, completion: { completed in
                    completion(completed: completed)
            })
        }
    }

    func hide(completion completion: (completed: Bool) -> Void) {
        switch config.presentationStyle {
        case .Top, .Bottom:
            UIView.animateWithDuration(0.2, delay: 0, options: [.BeginFromCurrentState, .CurveEaseIn], animations: {
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
// TODO the spring animation makes the interactive hide transition smoother, but
// TODO the added delay due to damping makes status bar style transitions look bad.
// TODO need to find an animation technique that accommodates both concerns.
//            let size = self.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
//            // Travel a bit further to account for possible drop shadow
//            let translationDistance = size.height - panTranslationY
//            let initialSpringVelocity = size.height == 0.0 ? 0.0 : closeSpeed / translationDistance
//            UIView.animateWithDuration(0.35, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: initialSpringVelocity, options: [.BeginFromCurrentState, .CurveLinear], animations: {
//                self.translationConstraint.constant -= translationDistance
//                self.view.superview?.layoutIfNeeded()
//            }, completion: { (completed) in
//                if let viewController = self.presentationContext.value as? WindowViewController {
//                    viewController.uninstall()
//                }
//                self.maskingView.removeFromSuperview()
//                completion(completed: completed)
//            })
        }
        
        func undim() {
            UIView.animateWithDuration(0.2, animations: {
                self.maskingView.backgroundColor = UIColor.clearColor()
            })
        }
        
        switch config.dimMode {
        case .None:
            break
        case .Gray:
            undim()
        case .Color:
            undim()
        }
    }
    
    private var bounceOffset: CGFloat {
        var bounceOffset: CGFloat = 5.0
        if let adjustable = view as? MarginAdjustable {
            bounceOffset = adjustable.bounceAnimationOffset
        }
        return bounceOffset
    }
    
    /*
     MARK: - Swipe to close
     */
    
    private var closing = false
    private var closeSpeed: CGFloat = 0.0
    private var closePercent: CGFloat = 0.0
    private var panTranslationY: CGFloat = 0.0
    
    @objc func pan(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .Changed:
            let backgroundView = panBackgroundView
            let backgroundHeight = backgroundView.bounds.height - bounceOffset
            if backgroundHeight <= 0 { return }
            let point = pan.locationOfTouch(0, inView: backgroundView)
            var velocity = pan.velocityInView(backgroundView)
            var translation = pan.translationInView(backgroundView)
            if case .Top = config.presentationStyle {
                velocity.y *= -1.0
                translation.y *= -1.0
            }
            if !closing {
                if CGRectContainsPoint(backgroundView.bounds, point) && velocity.y > 0.0 && velocity.x / velocity.y < 5.0 {
                    closing = true
                    pan.setTranslation(CGPointZero, inView: backgroundView)
                    delegate?.panStarted(presenter: self)
                }
            }
            if !closing { return }
            let translationAmount = -bounceOffset - max(0.0, translation.y)
            translationConstraint.constant = translationAmount
            closeSpeed = velocity.y
            closePercent = translation.y / backgroundHeight
            panTranslationY = translation.y
        case .Ended, .Cancelled:
            if closeSpeed > 750.0 || closePercent > 0.33 {
                delegate?.hide(presenter: self)
            } else {
                closing = false
                closeSpeed = 0.0
                closePercent = 0.0
                panTranslationY = 0.0
                showViewAnimation(completion: { (completed) in
                    self.delegate?.panEnded(presenter: self)
                })
            }
        default:
            break
        }
    }

    private var panBackgroundView: UIView {
        if let view = view as? BackgroundViewable {
            return view.backgroundView
        } else {
            return view
        }
    }
    
    private func shouldBeginPan(pan: UIGestureRecognizer) -> Bool {
        let backgroundView = panBackgroundView
        let point = pan.locationOfTouch(0, inView: backgroundView)
        return CGRectContainsPoint(backgroundView.bounds, point)
    }
    
    /*
     MARK: - UIGestureRecognizerDelegate
     */
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panRecognizer {
            return shouldBeginPan(gestureRecognizer)
        }
        return true
    }
}
