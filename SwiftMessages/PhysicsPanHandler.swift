//
//  PhysicsPanHandler.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/25/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

open class PhysicsPanHandler {

    public struct MotionSnapshot {
        var angle: CGFloat
        var time: CFAbsoluteTime
    }

    public final class State {

        weak var messageView: UIView?
        weak var containerView: UIView?
        var dynamicAnimator: UIDynamicAnimator
        var itemBehavior: UIDynamicItemBehavior
        var attachmentBehavior: UIAttachmentBehavior? {
            didSet {
                if let oldValue = oldValue {
                    dynamicAnimator.removeBehavior(oldValue)
                }
                if let attachmentBehavior = attachmentBehavior {
                    dynamicAnimator.addBehavior(attachmentBehavior)
                    addSnapshot()
                }
            }
        }
        var snapshots: [MotionSnapshot] = []

        public init(messageView: UIView, containerView: UIView) {
            self.messageView = messageView
            self.containerView = containerView
            let dynamicAnimator = UIDynamicAnimator(referenceView: containerView)
            let itemBehavior = UIDynamicItemBehavior(items: [messageView])
            itemBehavior.allowsRotation = true
            dynamicAnimator.addBehavior(itemBehavior)
            self.itemBehavior = itemBehavior
            self.dynamicAnimator = dynamicAnimator
        }

        func update(attachmentAnchorPoint anchorPoint: CGPoint) {
            addSnapshot()
            attachmentBehavior?.anchorPoint = anchorPoint
        }

        func addSnapshot() {
            let angle = messageView?.angle ?? snapshots.last?.angle ?? 0
            let time = CFAbsoluteTimeGetCurrent()
            snapshots.append(MotionSnapshot(angle: angle, time: time))
        }

        public func stop() {
            guard let messageView = messageView else {
                dynamicAnimator.removeAllBehaviors()
                return
            }
            let center = messageView.center
            let transform = messageView.transform
            dynamicAnimator.removeAllBehaviors()
            messageView.center = center
            messageView.transform = transform
        }

        public var angularVelocity: CGFloat {
            guard let last = snapshots.last else { return 0 }
            for previous in snapshots.reversed() {
                // Ignore snapshots where the angle or time hasn't changed to avoid degenerate cases.
                if previous.angle != last.angle && previous.time != last.time {
                    return (last.angle - previous.angle) / CGFloat(last.time - previous.time)
                }
            }
            return 0
        }
    }

    weak var animator: Animator?
    weak var messageView: UIView?
    weak var containerView: UIView?
    private(set) public var state: State?
    private(set) public var isOffScreen = false
    private var restingCenter: CGPoint?

    public init(context: AnimationContext, animator: Animator) {
        messageView = context.messageView
        containerView = context.containerView
        self.animator = animator
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(pan(_:)))
        if let view = messageView as? BackgroundViewable {
            view.backgroundView.addGestureRecognizer(pan)
        } else {
            context.messageView.addGestureRecognizer(pan)
        }
    }

    @objc func pan(_ pan: UIPanGestureRecognizer) {
        guard let messageView = messageView, let containerView = containerView, let animator = animator else { return }
        let anchorPoint = pan.location(in: containerView)
        switch pan.state {
        case .began:
            configureSafeAreaWorkaround()
            animator.delegate?.panStarted(animator: animator)
            let state = State(messageView: messageView, containerView: containerView)
            self.state = state
            let center = messageView.center
            restingCenter = center
            let offset = UIOffset(horizontal: anchorPoint.x - center.x, vertical: anchorPoint.y - center.y)
            let attachmentBehavior = UIAttachmentBehavior(item: messageView, offsetFromCenter: offset, attachedToAnchor: anchorPoint)
            state.attachmentBehavior = attachmentBehavior
            state.itemBehavior.action = { [weak self, weak messageView, weak containerView] in
                guard let strongSelf = self, let messageView = messageView, let containerView = containerView, let animator = strongSelf.animator else { return }
                let view = (messageView as? BackgroundViewable)?.backgroundView ?? messageView
                let frame = containerView.convert(view.bounds, from: view)
                if !containerView.bounds.intersects(frame) {
                    strongSelf.isOffScreen = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        animator.delegate?.hide(animator: animator)
                    }
                }
            }
        case .changed:
            guard let state = state else { return }
            state.update(attachmentAnchorPoint: anchorPoint)
        case .ended, .cancelled:
            guard let state = state else { return }
            state.update(attachmentAnchorPoint: anchorPoint)
            let velocity = pan.velocity(in: containerView)
            let angularVelocity = state.angularVelocity
            let speed = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
            // The multiplier on angular velocity was determined by hand-tuning
            let energy = sqrt(pow(speed, 2) + pow(angularVelocity * 75, 2))
            if energy > 200 && speed > 600 {
                // Limit the speed and angular velocity to reasonable values
                let speedScale = speed > 0 ? min(1, 1800 / speed) : 1
                let escapeVelocity = CGPoint(x: velocity.x * speedScale, y: velocity.y * speedScale)
                let angularSpeedScale = min(1, 10 / fabs(angularVelocity))
                let escapeAngularVelocity = angularVelocity * angularSpeedScale
                state.itemBehavior.addLinearVelocity(escapeVelocity, for: messageView)
                state.itemBehavior.addAngularVelocity(escapeAngularVelocity, for: messageView)
                state.attachmentBehavior = nil
            } else {
                // Undo any changes made to the layoutMargins of these views if the gesture doesn't
                // resolve in dismissing the messageView
                removeSafeAreaWorkaround()
                animator.delegate?.panEnded(animator: animator)
                state.stop()
                self.state = nil
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
                    messageView.center = self.restingCenter ?? CGPoint(x: containerView.bounds.width / 2, y: containerView.bounds.height / 2)
                    messageView.transform = CGAffineTransform.identity
                }, completion: nil)
            }
            // Don't retain any references to these views outside of this gesture
            originalSafeAreaWorkaroundValues.removeAll()
        default:
            break
        }
    }
    
    private var originalSafeAreaWorkaroundValues = [UIView: (layoutMargins: UIEdgeInsets, safeAreaInsets: UIEdgeInsets, layoutMarginsFromSafeArea: Bool)]()

    private func configureSafeAreaWorkaround() {
        guard #available(iOS 11, *), let messageView = messageView else { return }
        // Freeze the layout margins (with respect to safe area) in order to work
        // around a visual glitch (bug?) on iOS 11 where the message view's motion
        // becomes temporarily discontinuous. The problem can be seen in the Demo app's
        // "Centered" example by panning or flinging the message view upwards while
        // the device in portrait orientation. As the message view enters the top safe area,
        // the top layout margin gets a proportinal increase, causing the background view's
        // vertical velocity to abruptly go to zero. Once fully inside the safe area, the
        // layout margin has reached its maximum value and the vertical velocity abruptly
        // resumes. By freezing the layout margins here (the message view's resting layout
        // would have already been established), we completely avoid the problem. Strangely,
        // this problem doesn't affect left, right or bottom safe areas or any device
        // orientation other than portrait. The original values are cached for unfreezing
        // if the pan gesture doesn't resolve in dismissing the messageView, so if bounds
        // or orientations change while the message is visible later, it handles safeAreas properly.
        func freezeLayoutMargins(view: UIView) {
            let margins = view.layoutMargins
            originalSafeAreaWorkaroundValues[view] = (view.layoutMargins, view.safeAreaInsets, view.insetsLayoutMarginsFromSafeArea)
            view.insetsLayoutMarginsFromSafeArea = false
            view.layoutMargins = margins
            view.subviews.forEach { freezeLayoutMargins(view: $0) }
        }
        freezeLayoutMargins(view: messageView)
    }
    
    private func removeSafeAreaWorkaround() {
        guard #available(iOS 11, *), let messageView = messageView else { return }
        // Undo any changes to the margins of messageView or its children. If the view
        // originally had its layoutMargins inset from safe areas, subtract those values
        // from their original margins and reapply them.
        func unfreezeLayoutMargins(view: UIView) {
            guard let originalValues = originalSafeAreaWorkaroundValues[view] else { return }
            var newMargins = originalValues.layoutMargins
            if originalValues.layoutMarginsFromSafeArea {
                newMargins.top -= originalValues.safeAreaInsets.top
                newMargins.left -= originalValues.safeAreaInsets.left
                newMargins.right -= originalValues.safeAreaInsets.right
                newMargins.bottom -= originalValues.safeAreaInsets.bottom
            }
            view.insetsLayoutMarginsFromSafeArea = originalValues.layoutMarginsFromSafeArea
            view.layoutMargins = newMargins
            view.subviews.forEach { unfreezeLayoutMargins(view: $0) }
        }
        unfreezeLayoutMargins(view: messageView)
        // Enforce messageView and its children have their correct safeAreaInsets before we animate
        messageView.layoutIfNeeded()
    }
}

extension UIView {
    var angle: CGFloat {
        // http://stackoverflow.com/a/2051861/1271826
        return atan2(transform.b, transform.a)
    }
}
