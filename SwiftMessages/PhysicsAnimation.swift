//
//  PhysicsAnimation.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/14/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

@MainActor
public class PhysicsAnimation: NSObject, Animator {

    public enum Placement {
        case top
        case center
        case bottom
    }

    open var placement: Placement = .center

    open var showDuration: TimeInterval = 0.5

    open var hideDuration: TimeInterval = 0.15

    public var panHandler = PhysicsPanHandler()

    public weak var delegate: AnimationDelegate?
    weak var messageView: UIView?
    weak var containerView: UIView?
    var context: AnimationContext?

    public override init() {}

    init(delegate: AnimationDelegate) {
        self.delegate = delegate
    }

    public func show(context: AnimationContext, completion: @escaping AnimationCompletion) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustMargins),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        install(context: context)
        showAnimation(context: context, completion: completion)
    }

    public func hide(context: AnimationContext, completion: @escaping AnimationCompletion) {
        NotificationCenter.default.removeObserver(self)
        if panHandler.isOffScreen {
            context.messageView.alpha = 0
            panHandler.state?.stop()
        }
        let view = context.messageView
        self.context = context
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            view.alpha = 1
            view.transform = CGAffineTransform.identity
            completion(true)
        }
        UIView.animate(
            withDuration: hideDuration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], 
            animations: {
                view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, 
            completion: nil
        )
        UIView.animate(
            withDuration: hideDuration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction],
            animations: {
                view.alpha = 0
            },
            completion: nil
        )
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
            view.centerYAnchor.constraint(
                equalTo: container.centerYAnchor
            )
            .with(priority: UILayoutPriority(200))
            .isActive = true
        case .top:
            view.topAnchor.constraint(
                equalTo: container.topAnchor
            )
            .with(priority: UILayoutPriority(200))
            .isActive = true
        case .bottom:
            view.bottomAnchor.constraint(
                equalTo: container.bottomAnchor
            )
            .with(priority: UILayoutPriority(200))
            .isActive = true
        }
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            // Don't allow the message to spill outside of the top or bottom of the container.
            view.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor),
            view.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor),
        ])
        // Important to layout now in order to get the right safe area insets
        container.layoutIfNeeded()
        adjustMargins()
        container.layoutIfNeeded()
        installInteractive(context: context)
    }

    @objc public func adjustMargins() {
        guard let adjustable = messageView as? MarginAdjustable & UIView,
            let context = context else { return }
        adjustable.preservesSuperviewLayoutMargins = false
        adjustable.insetsLayoutMarginsFromSafeArea = false
        adjustable.layoutMargins = adjustable.defaultMarginAdjustment(context: context)
    }

    func showAnimation(context: AnimationContext, completion: @escaping AnimationCompletion) {
        let view = context.messageView
        view.alpha = 0.25
        view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion(true)
        }
        UIView.animate(withDuration: showDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            view.transform = CGAffineTransform.identity
        }, completion: nil)
        UIView.animate(withDuration: 0.3 * showDuration, delay: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            view.alpha = 1
        }, completion: nil)
        CATransaction.commit()
    }

    func installInteractive(context: AnimationContext) {
        guard context.interactiveHide else { return }
        panHandler.configure(context: context, animator: self)
    }
}


