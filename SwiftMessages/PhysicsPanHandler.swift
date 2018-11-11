//
//  PhysicsPanHandler.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/25/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

open class PhysicsPanHandler {

    public var hideDelay: TimeInterval = 0.2

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

    public init() {}

    lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(pan(_:)))
        return pan
    }()

    func configure(context: AnimationContext, animator: Animator) {
        if let oldView = (messageView as? BackgroundViewable)?.backgroundView ?? messageView {
            oldView.removeGestureRecognizer(pan)
        }
        messageView = context.messageView
        let view = (messageView as? BackgroundViewable)?.backgroundView ?? messageView
        view?.addGestureRecognizer(pan)
        containerView = context.containerView
        self.animator = animator
    }

    @objc func pan(_ pan: UIPanGestureRecognizer) {
        guard let messageView = messageView, let containerView = containerView, let animator = animator else { return }
        let anchorPoint = pan.location(in: containerView)
        switch pan.state {
        case .began:
            animator.delegate?.panStarted(animator: animator)
            let state = State(messageView: messageView, containerView: containerView)
            self.state = state
            let center = messageView.center
            restingCenter = center
            let offset = UIOffset(horizontal: anchorPoint.x - center.x, vertical: anchorPoint.y - center.y)
            let attachmentBehavior = UIAttachmentBehavior(item: messageView, offsetFromCenter: offset, attachedToAnchor: anchorPoint)
            state.attachmentBehavior = attachmentBehavior
            state.itemBehavior.action = { [weak self, weak messageView, weak containerView] in
                guard let self = self, !self.isOffScreen, let messageView = messageView, let containerView = containerView, let animator = self.animator else { return }
                let view = (messageView as? BackgroundViewable)?.backgroundView ?? messageView
                let frame = containerView.convert(view.bounds, from: view)
                if !containerView.bounds.intersects(frame) {
                    self.isOffScreen = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.hideDelay) {
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
                let angularSpeedScale = min(1, 10 / abs(angularVelocity))
                let escapeAngularVelocity = angularVelocity * angularSpeedScale
                state.itemBehavior.addLinearVelocity(escapeVelocity, for: messageView)
                state.itemBehavior.addAngularVelocity(escapeAngularVelocity, for: messageView)
                state.attachmentBehavior = nil
            } else {
                state.stop()
                self.state = nil
                animator.delegate?.panEnded(animator: animator)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
                    messageView.center = self.restingCenter ?? CGPoint(x: containerView.bounds.width / 2, y: containerView.bounds.height / 2)
                    messageView.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        default:
            break
        }
    }
}

extension UIView {
    var angle: CGFloat {
        // http://stackoverflow.com/a/2051861/1271826
        return atan2(transform.b, transform.a)
    }
}
