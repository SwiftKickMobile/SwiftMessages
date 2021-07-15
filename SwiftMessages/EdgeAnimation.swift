//
//  EdgeAnimation.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/4/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

public class EdgeAnimation: NSObject, Animator {

    public enum Style {
        case top
        case bottom
        case leading
        case trailing
    }

    public weak var delegate: AnimationDelegate?

    public let style: Style

    public var showDuration: TimeInterval = 0.35

    public var hideDuration: TimeInterval = 0.25

    public var springDamping: CGFloat = 0.8

    public var closeSpeedThreshold: CGFloat = 750.0;

    public var closePercentThreshold: CGFloat = 0.33;

    public var closeAbsoluteThreshold: CGFloat = 75.0;

    public private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(pan(_:)))
        return pan
    }()

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
        NotificationCenter.default.addObserver(self, selector: #selector(adjustMargins), name: UIDevice.orientationDidChangeNotification, object: nil)
        install(context: context)
        showAnimation(completion: completion)
    }

    public func hide(context: AnimationContext, completion: @escaping AnimationCompletion) {
        NotificationCenter.default.removeObserver(self)
        let view = context.messageView
        self.context = context
        let leftTransform = CGAffineTransform(translationX: -view.frame.width, y: 0)
        let rightTransform = CGAffineTransform(translationX: view.frame.maxX + view.frame.width, y: 0)
        UIView.animate(withDuration: hideDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState]) {
            switch self.style {
            case .top:
                view.transform = CGAffineTransform(translationX: 0, y: -view.frame.height)
            case .bottom:
                view.transform = CGAffineTransform(translationX: 0, y: view.frame.maxY + view.frame.height)
            case .leading:
                switch view.traitCollection.layoutDirection {
                case .leftToRight, .unspecified: view.transform = leftTransform
                case .rightToLeft: view.transform = rightTransform
                @unknown default: view.transform = leftTransform
                }
            case .trailing:
                switch view.traitCollection.layoutDirection {
                case .leftToRight, .unspecified: view.transform = rightTransform
                case .rightToLeft: view.transform = leftTransform
                @unknown default: view.transform = rightTransform
                }
            }
        } completion: { completed in
            #if SWIFTMESSAGES_APP_EXTENSIONS
            completion(completed)
            #else
            // Fix #131 by always completing if application isn't active.
            completion(completed || UIApplication.shared.applicationState != .active)
            #endif
        }
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
        if let layoutDefiningView = view as? LayoutDefining & UIView {
            container.install(layoutDefiningView: layoutDefiningView)
        } else {
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
        }
        // Horizontal constraints
        do {
        }
        switch style {
        case .top:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor)
                    .with(priority: .belowMessageSizeable - 1),
                view.centerXAnchor.constraint(equalTo: container.centerXAnchor)
                    .with(priority: .belowMessageSizeable),
                view.topAnchor.constraint(equalTo: container.topAnchor, constant: -bounceOffset)
                    .with(priority: .belowMessageSizeable)
            ])
        case .bottom:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor)
                    .with(priority: .belowMessageSizeable - 1),
                view.centerXAnchor.constraint(equalTo: container.centerXAnchor)
                    .with(priority: .belowMessageSizeable),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: bounceOffset)
                    .with(priority: .belowMessageSizeable)
            ])
        case .leading:
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: container.topAnchor)
                    .with(priority: .belowMessageSizeable - 1),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor)
                    .with(priority: .belowMessageSizeable),
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: -bounceOffset)
                    .with(priority: .belowMessageSizeable)
            ])
        case .trailing:
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: container.topAnchor)
                    .with(priority: .belowMessageSizeable - 1),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor)
                    .with(priority: .belowMessageSizeable),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: bounceOffset)
                    .with(priority: .belowMessageSizeable)
            ])
        }
        // Important to layout now in order to get the right safe area insets
        container.layoutIfNeeded()
        adjustMargins()
        container.layoutIfNeeded()
        let leftTransform = CGAffineTransform(translationX: -view.frame.width, y: 0)
        let rightTransform = CGAffineTransform(translationX: view.frame.maxX + view.frame.width, y: 0)
        switch style {
        case .top:
            view.transform = CGAffineTransform(translationX: 0, y: -view.frame.height)
        case .bottom:
            view.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        case .leading:
            switch view.traitCollection.layoutDirection {
            case .leftToRight, .unspecified: view.transform = leftTransform
            case .rightToLeft: view.transform = rightTransform
            @unknown default: view.transform = leftTransform
            }
        case .trailing:
            switch view.traitCollection.layoutDirection {
            case .leftToRight, .unspecified: view.transform = rightTransform
            case .rightToLeft: view.transform = leftTransform
            @unknown default: view.transform = rightTransform
            }
        }
        if context.interactiveHide {
            if let view = view as? BackgroundViewable {
                view.backgroundView.addGestureRecognizer(panGestureRecognizer)
            } else {
                view.addGestureRecognizer(panGestureRecognizer)
            }
        }
        if let view = view as? BackgroundViewable & UIView,
            let cornerRoundingView = view.backgroundView as? CornerRoundingView,
            cornerRoundingView.roundsLeadingCorners {
            let left: UIRectCorner = [.topLeft, .bottomLeft]
            let right: UIRectCorner = [.topRight, .bottomRight]
            switch style {
            case .top:
                cornerRoundingView.roundedCorners = [.bottomLeft, .bottomRight]
            case .bottom:
                cornerRoundingView.roundedCorners = [.topLeft, .topRight]
            case .leading:
                switch view.traitCollection.layoutDirection {
                case .leftToRight, .unspecified: cornerRoundingView.roundedCorners = right
                case .rightToLeft: cornerRoundingView.roundedCorners = left
                @unknown default: cornerRoundingView.roundedCorners = right
                }
            case .trailing:
                switch view.traitCollection.layoutDirection {
                case .leftToRight, .unspecified: cornerRoundingView.roundedCorners = left
                case .rightToLeft: cornerRoundingView.roundedCorners = right
                @unknown default: cornerRoundingView.roundedCorners = left
                }
            }
        }
    }

    @objc public func adjustMargins() {
        guard let adjustable = messageView as? MarginAdjustable & UIView,
            let context = context else { return }
        adjustable.preservesSuperviewLayoutMargins = false
        adjustable.insetsLayoutMarginsFromSafeArea = false
        var layoutMargins = adjustable.defaultMarginAdjustment(context: context)
        switch style {
        case .top:
            layoutMargins.top += bounceOffset
        case .bottom:
            layoutMargins.bottom += bounceOffset
        case .leading:
            layoutMargins.left += bounceOffset
        case .trailing:
            layoutMargins.right += bounceOffset
        }
        adjustable.layoutMargins = layoutMargins
    }

    func showAnimation(completion: @escaping AnimationCompletion) {
        guard let view = messageView else {
            completion(false)
            return
        }
        let animationDistance = abs(view.transform.ty)
        // Cap the initial velocity at zero because the bounceOffset may not be great
        // enough to allow for greater bounce induced by a quick panning motion.
        let initialSpringVelocity = animationDistance == 0.0 ? 0.0 : min(0.0, closeSpeed / animationDistance)
        UIView.animate(withDuration: showDuration, delay: 0.0, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            view.transform = .identity
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
    fileprivate var rubberBanding = false
    fileprivate var closeSpeed: CGFloat = 0.0
    fileprivate var closePercent: CGFloat = 0.0
    fileprivate var panTranslation: CGFloat = 0.0

    @objc func pan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .changed:
            guard let view = messageView else { return }
            let length: CGFloat
            switch style {
            case .top, .bottom:
                length = view.bounds.height - bounceOffset
            case .leading, .trailing:
                length = view.bounds.width - bounceOffset
            }
            if length <= 0 { return }
            var velocity = pan.velocity(in: view)
            var translation = pan.translation(in: view)
            switch style {
            case .top:
                velocity.y *= -1.0
                translation.y *= -1.0
            case .leading:
                velocity.x *= -1.0
                translation.x *= -1.0
            case .bottom, .trailing:
                break
            }
            var translationAmount: CGFloat
            switch style {
            case .top, .bottom:
                translationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.7)
            case .leading, .trailing:
                translationAmount = translation.x >= 0 ? translation.x : -pow(abs(translation.x), 0.7)
            }
            if !closing {
                // Turn on rubber banding if background view is inset from message view.
                if let background = (messageView as? BackgroundViewable)?.backgroundView, background != view {
                    switch style {
                    case .top:
                        rubberBanding = background.frame.minY > 0
                    case .bottom:
                        rubberBanding = background.frame.maxY < view.bounds.height
                    case .leading:
                        rubberBanding = background.frame.minX > 0
                    case .trailing:
                        rubberBanding = background.frame.maxX < view.bounds.width
                    }
                }
                if !rubberBanding && translationAmount < 0 { return }
                closing = true
                delegate?.panStarted(animator: self)
            }
            if !rubberBanding && translationAmount < 0 { translationAmount = 0 }
            switch style {
            case .top:
                view.transform = CGAffineTransform(translationX: 0, y: -translationAmount)
            case .bottom:
                view.transform = CGAffineTransform(translationX: 0, y: translationAmount)
            case .leading:
                view.transform = CGAffineTransform(translationX: -translationAmount, y: 0)
            case .trailing:
                view.transform = CGAffineTransform(translationX: translationAmount, y: 0)
            }
            switch style {
            case .top, .bottom:
                closeSpeed = velocity.y
                closePercent = translation.y / length
                panTranslation = translation.y
            case .leading, .trailing:
                closeSpeed = velocity.x
                closePercent = translation.x / length
                panTranslation = translation.x
            }
        case .ended, .cancelled:
            if closeSpeed > closeSpeedThreshold || closePercent > closePercentThreshold || panTranslation > closeAbsoluteThreshold {
                delegate?.hide(animator: self)
            } else {
                closing = false
                rubberBanding = false
                closeSpeed = 0.0
                closePercent = 0.0
                panTranslation = 0.0
                showAnimation(completion: { (completed) in
                    self.delegate?.panEnded(animator: self)
                })
            }
        default:
            break
        }
    }
}
