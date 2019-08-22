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

    public var panHandler = PhysicsPanHandler()

    public weak var delegate: AnimationDelegate?
    weak var messageView: UIView?
    weak var containerView: UIView?
    var context: AnimationContext?
    var keyboardHeight : CGFloat = 0.0
    public override init() {}

    init(delegate: AnimationDelegate) {
        self.delegate = delegate
    }

    public func show(context: AnimationContext, completion: @escaping AnimationCompletion) {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustMargins), name: UIDevice.orientationDidChangeNotification, object: nil)
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
        UIView.animate(withDuration: hideDuration!, delay: 0, options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], animations: {
            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
        UIView.animate(withDuration: hideDuration!, delay: 0, options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], animations: {
            view.alpha = 0
        }, completion: nil)
        CATransaction.commit()
    }

    public var showDuration: TimeInterval? { return 0.5  }

    public var hideDuration: TimeInterval? { return 0.15  }

    func install(context: AnimationContext) {
        NotificationCenter.default.addObserver(self, selector: .keyboardWillShow, name: UIResponder.keyboardWillShowNotification, object: nil)

        let view = context.messageView
        let container = context.containerView
        messageView = view
        containerView = container
        self.context = context
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        switch placement {
        case .center:
            let screenSize = UIScreen.main.bounds
            let screenHeight = screenSize.height
            if screenHeight <= 568.0 || UIDevice.current.userInterfaceIdiom == .pad {
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: screenHeight/2 - (self.keyboardHeight + 125)).with(priority: UILayoutPriority(200)).isActive = true
            } else{
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor).with(priority: UILayoutPriority(200)).isActive = true
            }
            
//            print("screenHeight \(screenHeight)")
//            if screenHeight <= 568.0  {
//                UIView.animate(withDuration: 0.5) {
//                    view.frame = CGRect(x: view.frame.origin.x,
//                                        y: view.frame.origin.y - 100,
//                                        width: view.frame.width, height: view.frame.height )
//                }
//            }
        case .top:
            view.topAnchor.constraint(equalTo: container.topAnchor).with(priority: UILayoutPriority(200)).isActive = true
        case .bottom:
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor).with(priority: UILayoutPriority(200)).isActive = true
        }
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
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
        if #available(iOS 11, *) {
            adjustable.insetsLayoutMarginsFromSafeArea = false
        }
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
        UIView.animate(withDuration: showDuration!, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            view.transform = CGAffineTransform.identity
        }, completion: nil)
        UIView.animate(withDuration: 0.3 * showDuration!, delay: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            view.alpha = 1
        }, completion: nil)
        CATransaction.commit()
    }
    @objc fileprivate func keyboardWillShow(notification:NSNotification) {
        if let keyboardRectValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
             self.keyboardHeight = keyboardRectValue.height
        }
    }
    
    func installInteractive(context: AnimationContext) {
        guard context.interactiveHide else { return }
        panHandler.configure(context: context, animator: self)
    }
}

private extension Selector {
    static let keyboardWillShow = #selector(PhysicsAnimation.keyboardWillShow(notification:))
}
