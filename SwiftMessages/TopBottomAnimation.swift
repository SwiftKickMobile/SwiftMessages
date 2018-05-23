//
//  TopBottomAnimation.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/4/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

public class TopBottomAnimation: NSObject, Animator {

    public enum Style {
        case top
        case bottom
    }

    public weak var delegate: AnimationDelegate?

    open let style: Style

    open var closeSpeedThreshold: CGFloat = 750.0;

    open var closePercentThreshold: CGFloat = 33.0;

    private(set) var translationConstraint: NSLayoutConstraint! = nil

    weak var messageView: UIView?
    weak var containerView: UIView?
    var context: AnimationContext?

    public init(style: Style) {
        self.style = style
    }

    init(style: Style, delegate: AnimationDelegate) {
        self.style = style
        self.delegate = delegate
    }

    public func show(context: AnimationContext, completion: @escaping AnimationCompletion) {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustMargins), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        install(context: context)
        showAnimation(completion: completion)
    }

    public func hide(context: AnimationContext, completion: @escaping AnimationCompletion) {
        NotificationCenter.default.removeObserver(self)
        let view = context.messageView
        let container = context.containerView
        self.context = context
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            let size = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            self.translationConstraint.constant -= size.height
            container.layoutIfNeeded()
        }, completion: { completed in
            #if SWIFTMESSAGES_APP_EXTENSIONS
            completion(completed)
            #else
            // Fix #131 by always completing if application isn't active.
            completion(completed || UIApplication.shared.applicationState != .active)
            #endif
        })
    }

    func install(context: AnimationContext) {
        let view = context.messageView
        let container = context.containerView
        messageView = view
        containerView = container
        self.context = context
        if let adjustable = context.messageView as? MarginAdjustable {
            bounceOffset = adjustable.bounceAnimationOffset
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        let leading = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.00, constant: 0.0)
        let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.00, constant: 0.0)
        switch style {
        case .top:
            translationConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.00, constant: 0.0)
        case .bottom:
            translationConstraint = NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.00, constant: 0.0)
        }
        container.addConstraints([leading, trailing, translationConstraint])
        // Important to layout now in order to get the right safe area insets
        container.layoutIfNeeded()
        adjustMargins()
        let size = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        translationConstraint.constant -= size.height
        container.layoutIfNeeded()
        if context.interactiveHide {
            let pan = UIPanGestureRecognizer()
            pan.addTarget(self, action: #selector(pan(_:)))
            if let view = view as? BackgroundViewable {
                view.backgroundView.addGestureRecognizer(pan)
            } else {
                view.addGestureRecognizer(pan)
            }
        }
    }

    @objc public func adjustMargins() {
        guard let adjustable = messageView as? MarginAdjustable & UIView,
            let context = context else { return }
        adjustable.preservesSuperviewLayoutMargins = false
        var defaultMarginAdjustment = adjustable.defaultMarginAdjustment(context: context)
        switch style {
        case .top:
            defaultMarginAdjustment.top += bounceOffset
        case .bottom:
            defaultMarginAdjustment.bottom += bounceOffset
        }
        if #available(iOS 11, *) {
            adjustable.insetsLayoutMarginsFromSafeArea = false
            adjustable.layoutMargins = adjustable.safeAreaInsets + defaultMarginAdjustment
        } else {
            adjustable.layoutMargins = defaultMarginAdjustment
        }
    }

    func showAnimation(completion: @escaping AnimationCompletion) {
        guard let container = containerView else {
            completion(false)
            return
        }
        let animationDistance = self.translationConstraint.constant + bounceOffset
        // Cap the initial velocity at zero because the bounceOffset may not be great
        // enough to allow for greater bounce induced by a quick panning motion.
        let initialSpringVelocity = animationDistance == 0.0 ? 0.0 : min(0.0, closeSpeed / animationDistance)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: initialSpringVelocity, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            self.translationConstraint.constant = -self.bounceOffset
            container.layoutIfNeeded()
        }, completion: { completed in
            // Fix #131 by always completing if application isn't active.
            #if SWIFTMESSAGES_APP_EXTENSIONS
            completion(completed)
            #else
            completion(completed || UIApplication.shared.applicationState != .active)
            #endif
        })
    }

    fileprivate var bounceOffset: CGFloat = 5

    /*
     MARK: - Pan to close
     */

    fileprivate var closing = false
    fileprivate var closeSpeed: CGFloat = 0.0
    fileprivate var closePercent: CGFloat = 0.0
    fileprivate var panTranslationY: CGFloat = 0.0

    @objc func pan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .changed:
            guard let view = pan.view else { return }
            let height = view.bounds.height - bounceOffset
            if height <= 0 { return }
            let point = pan.location(ofTouch: 0, in: view)
            var velocity = pan.velocity(in: view)
            var translation = pan.translation(in: view)
            if case .top = style {
                velocity.y *= -1.0
                translation.y *= -1.0
            }
            if !closing {
                if view.bounds.contains(point) && velocity.y > 0.0 && velocity.x / velocity.y < 5.0 {
                    closing = true
                    pan.setTranslation(CGPoint.zero, in: view)
                    delegate?.panStarted(animator: self)
                }
            }
            if !closing { return }
            let translationAmount = -bounceOffset - max(0.0, translation.y)
            translationConstraint.constant = translationAmount
            closeSpeed = velocity.y
            closePercent = translation.y / height
            panTranslationY = translation.y
        case .ended, .cancelled:
            if closeSpeed > closeSpeedThreshold || closePercent > closePercentThreshold {
                delegate?.hide(animator: self)
            } else {
                closing = false
                closeSpeed = 0.0
                closePercent = 0.0
                panTranslationY = 0.0
                showAnimation(completion: { (completed) in
                    self.delegate?.panEnded(animator: self)
                })
            }
        default:
            break
        }
    }
}
