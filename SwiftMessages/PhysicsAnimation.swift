//
//  PhysicsAnimation.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/14/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

public class PhysicsAnimation: NSObject, Animator {

    public enum Placement {
        case top
        case center
        case bottom
    }

    public var placement: Placement = .center

    public weak var delegate: AnimationDelegate?
    weak var messageView: UIView?
    weak var containerView: UIView?
    var context: AnimationContext?

    public override init() {}

    init(delegate: AnimationDelegate) {
        self.delegate = delegate
    }

    public func show(context: AnimationContext, completion: @escaping AnimationCompletion) {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustMargins), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        install(context: context)
        showAnimation(context: context, completion: completion)
    }

    public func hide(context: AnimationContext, completion: @escaping AnimationCompletion) {
        NotificationCenter.default.removeObserver(self)
        if panHandler?.isOffScreen ?? false {
            context.messageView.alpha = 0
            panHandler?.state?.stop()
        }
        let view = context.messageView
        self.context = context
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            view.alpha = 1
            view.transform = CGAffineTransform.identity
            completion(true)
        }
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], animations: {
            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], animations: {
            view.alpha = 0
        }, completion: nil)
        CATransaction.commit()
    }

    func install(context: AnimationContext) {
        let view = context.messageView
        let container = context.containerView
        messageView = view
        containerView = container
        self.context = context
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        switch placement {
        case .center:
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        case .top:
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0).isActive = true
        case .bottom:
            NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        }
        // Important to layout now in order to get the right safe area insets
        container.layoutIfNeeded()
        adjustMargins()
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        container.layoutIfNeeded()
        installInteractive(context: context)
    }

    @objc public func adjustMargins() {
        guard let adjustable = messageView as? MarginAdjustable & UIView,
            let context = context else { return }
        adjustable.preservesSuperviewLayoutMargins = false
        let defaultMarginAdjustment = adjustable.defaultMarginAdjustment(context: context)
        if #available(iOS 11, *) {
            adjustable.insetsLayoutMarginsFromSafeArea = false
            adjustable.layoutMargins = adjustable.safeAreaInsets + defaultMarginAdjustment
        } else {
            adjustable.layoutMargins = defaultMarginAdjustment
        }
    }

    func showAnimation(context: AnimationContext, completion: @escaping AnimationCompletion) {
        let view = context.messageView
        view.alpha = 0.25
        view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion(true)
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            view.transform = CGAffineTransform.identity
        }, completion: nil)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            view.alpha = 1
        }, completion: nil)
        CATransaction.commit()
    }

    var panHandler: PhysicsPanHandler?

    func installInteractive(context: AnimationContext) {
        guard context.interactiveHide else { return }
        panHandler = PhysicsPanHandler(context: context, animator: self)
    }
}


