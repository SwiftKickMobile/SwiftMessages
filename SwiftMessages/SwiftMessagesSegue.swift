//
//  SwiftMessagesSegue.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 5/30/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit

/**
 `SwiftMessagesSegue` is a configurable subclass of `UIStoryboardSegue` that utilizes
 SwiftMessages to present and dismiss modal view controllers. `SwiftMessagesSegue` performs
 these transitions by becoming your view controller's `transitioningDelegate`, calling
 SwiftMessage's `show()` and `hide()` under the hood.

 `SwiftMessagesSegue` is easy to use: start by selecting "swift messages" Manual Segue type
 when control-dragging a new segue in IB. If you need to set any of the `SwiftMessagesSegue`
 configuration options, you can do so in `prepare(for:sender:)` (ask Apple to
 support `IBInspectable` for segues!) or define your own self-configuring subclass.

 A number of pre-defined configurations are provided for your convenience in the form of
 self-configuring subclasses: `TopMessageSegue`, `BottomMessageSegue`, `TopCardSegue`,
 `BottomCardSegue`, and `CenteredSegue`. You'll see these in IB as Manual Segue types:
 "top message view", "bottom message view", "top card view", "bottom card view", and "centered view".

 The `SwiftMessagesSegue` class can alternatively be used programatically without an associated IB
 segue. Create an instance in the presenting view controller and call `perform()`:

     let destinationVC = ... // make a reference to a destination view controller
     let segue = BottomCardSegue(identifier: nil, source: self, destination: destinationVC)
     ... // do any configuration here
     segue.perform()

 To dismiss, call the UIKit API:

     dismiss(animated: true, completion: nil)

 It is not necessary to retain `segue` because it retains itself until dismissal. However, you can
 retain it if you plan to `perform()` more than once.

 + note: Some additional details:
 1. Your view controller's view will be embedded in a `SwiftMessages.BaseView` in order to
    utilize some SwiftMessages features. This view can be accessed and configured via the
    `SwiftMessagesSegue.messageView` property.
 2. Some view controllers' views do not define a good `intrinsicContentSize`, which
    SwiftMessages generally uses to establish the message view's height. A typical example
    is `UINavigationController`. As a workaround, you can specify an explicit height in your
    configuration:

        segue.messageView.preferredHeight = 300

 See the "View Controllers" selection in the Demo app for examples.
 */
open class SwiftMessagesSegue: UIStoryboardSegue {

    /**
     Specifies one of the pre-defined configurations, mirroring a subset of `MessageView.Layout`.
     */
    public enum Layout {

        /// The standard message view layout on top.
        case topMessage

        /// The standard message view layout on bottom.
        case bottomMessage

        /// A floating card-style view with rounded corners on top
        case topCard

        /// A floating tab-style view with rounded corners on bottom
        case topTab

        /// A floating card-style view with rounded corners on bottom
        case bottomCard

        /// A floating tab-style view with rounded corners on top
        case bottomTab

        /// A floating card-style view typically used with `.center` presentation style.
        case centered
    }

    /**
     Specifies how the view controller's view is installed into the
     containing message view.
     */
    public enum Containment {

        /**
         The view controller's view is installed using `BaseView.installContentView(:insets:)`.
         Use this option when the view controller's view should be edge-to-edge, extending into
         the margins (safe areas). See that method's documentation for details.
         */
        case content

        /**
         The view controller's view is installed using `BaseView.installBackgroundView(:insets:)`.
         Use this option for card-style layouts where the message view's background is transparent
         and the view controller's view is inset from the margins (safe area). See that method's
         documentation for details.
         */
        case background

        case backgroundVertical
    }

    /**
     The view that the view controller's view is installed into and displayed using
     `SwiftMessages.show()`. This class is responsible for performing the installation,
     but any other optional configuration of `messageView` is up to the caller.

     Note that some view controllers' views do not define a good `intrinsicContentSize`, which
     SwiftMessages generally relies on to establish the message view's height. A typical example
     is `UINavigationController`. As a workaround, you can specify an explicit height in your
     configuration using `StoryboardSegue.messageView.preferredHeight`.
     */
    public var messageView = BaseView()

    public var containerView = ViewControllerContainerView()

    /**
     Specifies how the view controller's view is installed into the
     containing message view.
     */
    public var containment: Containment = .content

    /// The presentation style to use. See the SwiftMessages.PresentationStyle documentation for details.
    public var presentationStyle: SwiftMessages.PresentationStyle {
        get { return messenger.defaultConfig.presentationStyle }
        set { messenger.defaultConfig.presentationStyle = newValue }
    }

    /// The dim mode to use. See the SwiftMessages.DimMode documentation for details.
    public var dimMode: SwiftMessages.DimMode {
        get { return messenger.defaultConfig.dimMode}
        set { messenger.defaultConfig.dimMode = newValue }
    }

    /// Specifies whether or not the interactive pan-to-hide gesture is enabled
    /// on the message view.
    public var interactiveHide: Bool {
        get { return messenger.defaultConfig.interactiveHide }
        set { messenger.defaultConfig.interactiveHide = newValue }
    }

    var bounces = true

    private var messenger = SwiftMessages()
    private var selfRetainer: SwiftMessagesSegue? = nil
    private lazy var hider = { return Hider(segue: self) }()

    private lazy var presenter = {
        return Presenter(config: messenger.defaultConfig, view: messageView, delegate: messenger)
    }()

    override open func perform() {
        selfRetainer = self
        destination.modalPresentationStyle = .custom
        destination.transitioningDelegate = self
        source.present(destination, animated: true, completion: nil)
    }

    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        dimMode = .gray(interactive: true)
        messenger.defaultConfig.duration = .forever
    }

    fileprivate let safeAreaWorkaroundViewController = UIViewController()
}

extension SwiftMessagesSegue {
    public func configure(layout: Layout) {
        messageView.bounceAnimationOffset = 0
        messageView.statusBarOffset = 0
        messageView.safeAreaTopOffset = 0
        messageView.safeAreaBottomOffset = 0
        containment = .content
        containerView.cornerRadius = 0
        containerView.roundsLeadingCorners = false
        messageView.configureDropShadow()
        switch layout {
        case .topMessage:
            messageView.layoutMarginAdditions = UIEdgeInsetsMake(20, 20, 20, 20)
            messageView.collapseLayoutMarginAdditions = false
            let animation = TopBottomAnimation(style: .top)
            animation.springDamping = 1
            presentationStyle = .custom(animator: animation)
        case .bottomMessage:
            messageView.layoutMarginAdditions = UIEdgeInsetsMake(20, 20, 20, 20)
            messageView.collapseLayoutMarginAdditions = false
            let animation = TopBottomAnimation(style: .bottom)
            animation.springDamping = 1
            presentationStyle = .custom(animator: animation)
        case .topCard:
            messageView.layoutMarginAdditions = UIEdgeInsetsMake(10, 10, 10, 10)
            messageView.collapseLayoutMarginAdditions = true
            containerView.cornerRadius = 15
            containment = .background
            let animation = TopBottomAnimation(style: .top)
            presentationStyle = .custom(animator: animation)
        case .bottomCard:
            messageView.layoutMarginAdditions = UIEdgeInsetsMake(10, 10, 10, 10)
            messageView.collapseLayoutMarginAdditions = true
            containerView.cornerRadius = 15
            containment = .background
            let animation = TopBottomAnimation(style: .bottom)
            presentationStyle = .custom(animator: animation)
        case .topTab:
            messageView.layoutMarginAdditions = UIEdgeInsetsMake(20, 10, 20, 10)
            messageView.collapseLayoutMarginAdditions = true
            containerView.cornerRadius = 15
            containerView.roundsLeadingCorners = true
            containment = .backgroundVertical
            let animation = TopBottomAnimation(style: .top)
            animation.springDamping = 1
            presentationStyle = .custom(animator: animation)
        case .bottomTab:
            messageView.layoutMarginAdditions = UIEdgeInsetsMake(20, 10, 20, 10)
            messageView.collapseLayoutMarginAdditions = true
            containerView.cornerRadius = 15
            containerView.roundsLeadingCorners = true
            containment = .backgroundVertical
            let animation = TopBottomAnimation(style: .bottom)
            animation.springDamping = 1
            presentationStyle = .custom(animator: animation)
        case .centered:
            messageView.layoutMarginAdditions = UIEdgeInsetsMake(20, 10, 20, 10)
            messageView.collapseLayoutMarginAdditions = true
            containment = .backgroundVertical
            containerView.cornerRadius = 15
            let animation = PhysicsAnimation()
            presentationStyle = .custom(animator: animation)
        }
    }
}

extension SwiftMessagesSegue: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let shower = Shower(segue: self)
        messenger.defaultConfig.eventListeners.append { [unowned self] in
            switch $0 {
            case .didShow:
                shower.completeTransition?(true)
            case .didHide:
                if let completeTransition = self.hider.completeTransition {
                    completeTransition(true)
                } else {
                    // Case where message is interinally hidden by SwiftMessages, such as with a
                    // dismiss gesture, rather than by view controller dismissal.
                    source.dismiss(animated: false, completion: nil)
                }
                self.selfRetainer = nil
            default: break
            }
        }
        return shower
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return hider
    }
}

extension SwiftMessagesSegue {
    private class Shower: NSObject, UIViewControllerAnimatedTransitioning {

        fileprivate private(set) var completeTransition: ((Bool) -> Void)?
        private weak var segue: SwiftMessagesSegue?

        fileprivate init(segue: SwiftMessagesSegue) {
            self.segue = segue
        }

        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return segue?.presenter.animator.showDuration ?? 0.5
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let segue = segue,
                let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
            }
            if #available(iOS 12, *) {}
            else if #available(iOS 11.0, *) {
                // This works around a bug in iOS 11 where the safe area of `messageView` (
                // and all ancestor views) is not set except on iPhone X. By assigning `messageView`
                // to a view controller, its safe area is set consistently. This bug has been resolved as
                // of Xcode 10 beta 2.
                segue.safeAreaWorkaroundViewController.view = segue.presenter.maskingView
            }
            completeTransition = transitionContext.completeTransition
            let transitionContainer = transitionContext.containerView
            // Setup the layout of the `toView`
            do {
                toView.translatesAutoresizingMaskIntoConstraints = false
                segue.containerView.addSubview(toView)
                toView.topAnchor.constraint(equalTo: segue.containerView.topAnchor).isActive = true
                toView.bottomAnchor.constraint(equalTo: segue.containerView.bottomAnchor).isActive = true
                toView.leftAnchor.constraint(equalTo: segue.containerView.leftAnchor).isActive = true
                toView.rightAnchor.constraint(equalTo: segue.containerView.rightAnchor).isActive = true
            }
            // Install the `toView` into the message view.
            switch segue.containment {
            case .content:
                segue.messageView.installContentView(segue.containerView)
            case .background:
                segue.messageView.installBackgroundView(segue.containerView)
            case .backgroundVertical:
                segue.messageView.installBackgroundVerticalView(segue.containerView)
            }
            segue.containerView.viewController = transitionContext.viewController(forKey: .to)
            segue.presenter.config.presentationContext = .view(transitionContainer)
            segue.messenger.show(presenter: segue.presenter)
        }
    }
}

extension SwiftMessagesSegue {
    private class Hider: NSObject, UIViewControllerAnimatedTransitioning {

        fileprivate private(set) var completeTransition: ((Bool) -> Void)?
        private weak var segue: SwiftMessagesSegue?

        fileprivate init(segue: SwiftMessagesSegue) {
            self.segue = segue
        }

        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return segue?.presenter.animator.hideDuration ?? 0.5
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let messenger = segue?.messenger else {
                transitionContext.completeTransition(false)
                return
            }
            completeTransition = transitionContext.completeTransition
            messenger.hide()
        }
    }
}
