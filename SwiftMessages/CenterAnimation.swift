//
//  CenterAnimation.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/14/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

public class CenterAnimation: NSObject, Animator {

    public weak var delegate: AnimationDelegate?
    weak var messageView: UIView?
    weak var containerView: UIView?

    init(delegate: AnimationDelegate) {
        self.delegate = delegate
    }

    public func show(context: AnimationContext, completion: @escaping AnimationCompletion) {
        install(context: context)
        showAnimation(context: context, completion: completion)
    }

    public func hide(context: AnimationContext, completion: @escaping AnimationCompletion) {
        if panHandler?.isOffScreen ?? false {
            context.messageView.alpha = 0
            panHandler?.state?.stop()
        }
        let view = context.messageView
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
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        let centerX = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.00, constant: 0.0)
        let centerY = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1.00, constant: 0.0)
        let leftMargin = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1.00, constant: 00.0)
        container.addConstraints([centerX, centerY, leftMargin])
        container.layoutIfNeeded()
        installInteractive(context: context)
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

