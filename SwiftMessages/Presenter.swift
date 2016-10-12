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
    func hide(presenter: Presenter)
    func panStarted(presenter: Presenter)
    func panEnded(presenter: Presenter)
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
    
    var pauseDuration: TimeInterval? {
        let duration: TimeInterval?
        switch self.config.duration {
        case .automatic:
            duration = 2.0
        case .seconds(let seconds):
            duration = seconds
        case .forever:
            duration = nil
        }
        return duration
    }
    
    func show(completion: @escaping (_ completed: Bool) -> Void) throws {
        try presentationContext.value = getPresentationContext()
        install()
        showAnimation(completion: completion)
    }
    
    func getPresentationContext() throws -> UIViewController {
        
        func newWindowViewController(_ windowLevel: UIWindowLevel) -> UIViewController {
            let viewController = WindowViewController(windowLevel: windowLevel, config: config)
            return viewController
        }
        
        switch config.presentationContext {
        case .automatic:
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                return rootViewController.sm_selectPresentationContextTopDown(config)
            } else {
                throw SwiftMessagesError.noRootViewController
            }
        case .window(let level):
            return newWindowViewController(level)
        case .viewController(let viewController):
            return viewController.sm_selectPresentationContextBottomUp(config)
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
        let containerView: UIView = presentationContext.view
        do {
            maskingView.translatesAutoresizingMaskIntoConstraints = false
            if let nav = presentationContext as? UINavigationController {
                containerView.insertSubview(maskingView, belowSubview: nav.navigationBar)
            } else if let tab = presentationContext as? UITabBarController {
                containerView.insertSubview(maskingView, belowSubview: tab.tabBar)
            } else {
                containerView.addSubview(maskingView)
            }
            let leading = NSLayoutConstraint(item: maskingView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.00, constant: 0.0)
            let trailing = NSLayoutConstraint(item: maskingView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.00, constant: 0.0)
            let top = topLayoutConstraint(view: maskingView, presentationContext: presentationContext)
            let bottom = bottomLayoutConstraint(view: maskingView, presentationContext: presentationContext)
            containerView.addConstraints([top, leading, bottom, trailing])
        }
        do {
            view.translatesAutoresizingMaskIntoConstraints = false
            maskingView.addSubview(view)
            let leading = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: maskingView, attribute: .leading, multiplier: 1.00, constant: 0.0)
            let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: maskingView, attribute: .trailing, multiplier: 1.00, constant: 0.0)
            switch config.presentationStyle {
            case .top:
                translationConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: maskingView, attribute: .top, multiplier: 1.00, constant: 0.0)
            case .bottom:
                translationConstraint = NSLayoutConstraint(item: maskingView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.00, constant: 0.0)
            }
            maskingView.addConstraints([leading, trailing, translationConstraint])
            if let adjustable = view as? MarginAdjustable {
                var top: CGFloat = 0.0
                var bottom: CGFloat = 0.0
                switch config.presentationStyle {
                case .top:
                    top += adjustable.bounceAnimationOffset
                    if !UIApplication.shared.isStatusBarHidden {
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
                case .bottom:
                    bottom += adjustable.bounceAnimationOffset
                }
                view.layoutMargins = UIEdgeInsets(top: top, left: 0.0, bottom: bottom, right: 0.0)
            }
            let size = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            translationConstraint.constant -= size.height
        }
        containerView.layoutIfNeeded()
        if config.interactiveHide {
            view.addGestureRecognizer(panRecognizer)
        }
        do {
            
            func setupInteractive(_ interactive: Bool) {
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
            case .none:
                break
            case .gray(let interactive):
                setupInteractive(interactive)
            case .color(_, let interactive):
                setupInteractive(interactive)
            }
        }
    }
    
    func topLayoutConstraint(view: UIView, presentationContext: UIViewController) -> NSLayoutConstraint {
        if case .top = config.presentationStyle, let nav = presentationContext as? UINavigationController, nav.sm_isVisible(view: nav.navigationBar) {
            return NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: nav.navigationBar, attribute: .bottom, multiplier: 1.00, constant: 0.0)
        }
        return NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: presentationContext.view, attribute: .top, multiplier: 1.00, constant: 0.0)
    }

    func bottomLayoutConstraint(view: UIView, presentationContext: UIViewController) -> NSLayoutConstraint {
        if case .bottom = config.presentationStyle, let tab = presentationContext as? UITabBarController, tab.sm_isVisible(view: tab.tabBar) {
            return NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: tab.tabBar, attribute: .top, multiplier: 1.00, constant: 0.0)
        }
        return NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: presentationContext.view, attribute: .bottom, multiplier: 1.00, constant: 0.0)
    }
    
    /*
     MARK: - Showing and hiding
     */

    func showAnimation(completion: @escaping (_ completed: Bool) -> Void) {

        showViewAnimation(completion: completion)
        
        func dim(_ color: UIColor) {
            self.maskingView.backgroundColor = UIColor.clear
            UIView.animate(withDuration: 0.2, animations: {
                self.maskingView.backgroundColor = color
            })
        }

        switch config.dimMode {
        case .none:
            break
        case .gray:
            dim(UIColor(white: 0, alpha: 0.3))
        case .color(let color, _):
            dim(color)
        }
    }

    func showViewAnimation(completion: @escaping (_ completed: Bool) -> Void) {
        
        switch config.presentationStyle {
        case .top, .bottom:
            let animationDistance = self.translationConstraint.constant + bounceOffset
            // Cap the initial velocity at zero because the bounceOffset may not be great
            // enough to allow for greater bounce induced by a quick panning motion.
            let initialSpringVelocity = animationDistance == 0.0 ? 0.0 : min(0.0, closeSpeed / animationDistance)
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: initialSpringVelocity, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
                self.translationConstraint.constant = -self.bounceOffset
                self.view.superview?.layoutIfNeeded()
                }, completion: { completed in
                    completion(completed)
            })
        }
    }

    func hide(completion: @escaping (_ completed: Bool) -> Void) {
        switch config.presentationStyle {
        case .top, .bottom:
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
                let size = self.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                self.translationConstraint.constant -= size.height
                self.view.superview?.layoutIfNeeded()
                }, completion: { completed in
                    if let viewController = self.presentationContext.value as? WindowViewController {
                        viewController.uninstall()
                    }
                    self.maskingView.removeFromSuperview()
                    completion(completed)
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
            UIView.animate(withDuration: 0.2, animations: {
                self.maskingView.backgroundColor = UIColor.clear
            })
        }
        
        switch config.dimMode {
        case .none:
            break
        case .gray:
            undim()
        case .color:
            undim()
        }
    }
    
    fileprivate var bounceOffset: CGFloat {
        var bounceOffset: CGFloat = 5.0
        if let adjustable = view as? MarginAdjustable {
            bounceOffset = adjustable.bounceAnimationOffset
        }
        return bounceOffset
    }
    
    /*
     MARK: - Swipe to close
     */
    
    fileprivate var closing = false
    fileprivate var closeSpeed: CGFloat = 0.0
    fileprivate var closePercent: CGFloat = 0.0
    fileprivate var panTranslationY: CGFloat = 0.0
    
    @objc func pan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .changed:
            let backgroundView = panBackgroundView
            let backgroundHeight = backgroundView.bounds.height - bounceOffset
            if backgroundHeight <= 0 { return }
            let point = pan.location(ofTouch: 0, in: backgroundView)
            var velocity = pan.velocity(in: backgroundView)
            var translation = pan.translation(in: backgroundView)
            if case .top = config.presentationStyle {
                velocity.y *= -1.0
                translation.y *= -1.0
            }
            if !closing {
                if backgroundView.bounds.contains(point) && velocity.y > 0.0 && velocity.x / velocity.y < 5.0 {
                    closing = true
                    pan.setTranslation(CGPoint.zero, in: backgroundView)
                    delegate?.panStarted(presenter: self)
                }
            }
            if !closing { return }
            let translationAmount = -bounceOffset - max(0.0, translation.y)
            translationConstraint.constant = translationAmount
            closeSpeed = velocity.y
            closePercent = translation.y / backgroundHeight
            panTranslationY = translation.y
        case .ended, .cancelled:
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

    fileprivate var panBackgroundView: UIView {
        if let view = view as? BackgroundViewable {
            return view.backgroundView
        } else {
            return view
        }
    }
    
    fileprivate func shouldBeginPan(_ pan: UIGestureRecognizer) -> Bool {
        let backgroundView = panBackgroundView
        let point = pan.location(ofTouch: 0, in: backgroundView)
        return backgroundView.bounds.contains(point)
    }
    
    /*
     MARK: - UIGestureRecognizerDelegate
     */
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panRecognizer {
            return shouldBeginPan(gestureRecognizer)
        }
        return true
    }
}
