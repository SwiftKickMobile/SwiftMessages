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
 SwiftMessages to present and dismiss modal view controllers. It performs these transitions by
 becoming your view controller's `transitioningDelegate` and calling SwiftMessage's `show()`
 and `hide()` under the hood.

 To use `SwiftMessagesSegue` with Interface Builder, control-drag a segue, then select
 "swift messages" from the Segue Type dialog. This configures a default transition. There are
 two suggested ways to further configure the transition by setting options on `SwiftMessagesSegue`.
 First, and recommended, you may subclass `SwiftMessagesSegue` and override `init(identifier:source:destination:)`.
 Subclasses will automatically appear in the segue type dialog using an auto-generated name (for example, the
 name for "VeryNiceSegue" would be "very nice"). Second, you may override `prepare(for:sender:)` in the
 presenting view controller and downcast the segue to `SwiftMessagesSegue`.

 `SwiftMessagesSegue` can be used without an associated storyboard or segue by doing the following in
 the presenting view controller.

     let destinationVC = ... // make a reference to a destination view controller
     let segue = SwiftMessagesSegue(identifier: nil, source: self, destination: destinationVC)
     ... // do any configuration here
     segue.perform()

 To dismiss, call the UIKit API on the presenting view controller:

     dismiss(animated: true, completion: nil)

 It is not necessary to retain `segue` because it retains itself until dismissal. However, you can
 retain it if you plan to `perform()` more than once.

 + note: Some additional details:
 1. Your view controller's view will be embedded in a `SwiftMessages.BaseView` in order to
    utilize some SwiftMessages features. This view can be accessed and configured via the
    `SwiftMessagesSegue.messageView` property. For example, you may configure a default drop
    shadow by calling `segue.messageView.configureDropShadow()`.
 2. SwiftMessages relies on a view's `intrinsicContentSize` to determine the height of a message.
    However, some view controllers' views does not define a good `intrinsicContentSize`
    (`UINavigationController` is a common example). For these cases, there are a couple of ways
    to specify the preferred height. First, you may set the `preferredContentSize` on the destination
    view controller (available as "Use Preferred Explicit Size" in IB's attribute inspector). Second,
    you may set `SwiftMessagesSegue.messageView.backgroundHeight`.

 See the "View Controllers" selection in the Demo app for examples.
 */

open class SwiftMessagesSegue: UIStoryboardSegue {

    /**
     Specifies one of the pre-defined layouts, mirroring a subset of `MessageView.Layout`.
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
         The view controller's view is installed for edge-to-edge display, extending into the safe areas
         to the device edges. This is done by calling `messageView.installContentView(:insets:)`
         See that method's documentation for additional details.
        */
        case content

        /**
         The view controller's view is installed for card-style layouts, inset from the margins
         and avoiding safe areas. This is done by calling `messageView.installBackgroundView(:insets:)`.
         See that method's documentation for details.
        */
        case background

        /**
         The view controller's view is installed for tab-style layouts, inset from the side margins, but extending
         to the device edge on the top or bottom. This is done by calling `messageView.installBackgroundVerticalView(:insets:)`.
         See that method's documentation for details.
         */
        case backgroundVertical
    }

    /// The presentation style to use. See the SwiftMessages.PresentationStyle for details.
    public var presentationStyle: SwiftMessages.PresentationStyle {
        get { return messenger.defaultConfig.presentationStyle }
        set { messenger.defaultConfig.presentationStyle = newValue }
    }

    /// The dim mode to use. See the SwiftMessages.DimMode for details.
    public var dimMode: SwiftMessages.DimMode {
        get { return messenger.defaultConfig.dimMode}
        set { messenger.defaultConfig.dimMode = newValue }
    }

    /// Specifies whether or not the interactive pan-to-hide gesture is enabled
    /// on the message view. The default value is `true`, but may not be appropriate
    /// for view controllers that use swipe or pan gestures.
    public var interactiveHide: Bool {
        get { return messenger.defaultConfig.interactiveHide }
        set { messenger.defaultConfig.interactiveHide = newValue }
    }

    /// Specifies an optional array of event listeners.
    public var eventListeners: [SwiftMessages.EventListener] {
        get { return messenger.defaultConfig.eventListeners }
        set { messenger.defaultConfig.eventListeners = newValue }
    }

    /**
     The view that is passed to `SwiftMessages.show(config:view:)` during presentation.
     The view controller's view is installed into `containerView`, which is itself installed
     into `messageView`. `SwiftMessagesSegue` does this installation automatically based on the
     value of the `containment` property. `BaseView` is the parent of `MessageView` and provides a
     number of configuration options that you may use. For example, you may configure a default drop
     shadow by calling `messageView.configureDropShadow()`.
     */
    public var messageView = BaseView()

    /**
     The view controller's view is embedded in `containerView` before being installed into
     `messageView`. This view provides configurable squircle (round) corners (see the parent
     class `CornerRoundingView`).
    */
    public var containerView = ViewControllerContainerView()

    /**
     Specifies how the view controller's view is installed into the
     containing message view. See `Containment` for details.
     */
    public var containment: Containment = .content

    private var messenger = SwiftMessages()
    private var selfRetainer: SwiftMessagesSegue? = nil
    private lazy var hider = { return TransitioningDismisser(segue: self) }()

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
    /// A convenience method for configuring some pre-defined layouts that mirror a subset of `MessageView.Layout`.
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
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            messageView.collapseLayoutMarginAdditions = false
            let animation = TopBottomAnimation(style: .top)
            animation.springDamping = 1
            presentationStyle = .custom(animator: animation)
        case .bottomMessage:
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            messageView.collapseLayoutMarginAdditions = false
            let animation = TopBottomAnimation(style: .bottom)
            animation.springDamping = 1
            presentationStyle = .custom(animator: animation)
        case .topCard:
            containment = .background
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            messageView.collapseLayoutMarginAdditions = true
            containerView.cornerRadius = 15
            presentationStyle = .top
        case .bottomCard:
            containment = .background
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            messageView.collapseLayoutMarginAdditions = true
            containerView.cornerRadius = 15
            presentationStyle = .bottom
        case .topTab:
            containment = .backgroundVertical
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
            messageView.collapseLayoutMarginAdditions = true
            containerView.cornerRadius = 15
            containerView.roundsLeadingCorners = true
            let animation = TopBottomAnimation(style: .top)
            animation.springDamping = 1
            presentationStyle = .custom(animator: animation)
        case .bottomTab:
            containment = .backgroundVertical
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
            messageView.collapseLayoutMarginAdditions = true
            containerView.cornerRadius = 15
            containerView.roundsLeadingCorners = true
            let animation = TopBottomAnimation(style: .bottom)
            animation.springDamping = 1
            presentationStyle = .custom(animator: animation)
        case .centered:
            containment = .backgroundVertical
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
            messageView.collapseLayoutMarginAdditions = true
            containerView.cornerRadius = 15
            presentationStyle = .center
        }
    }
}

extension SwiftMessagesSegue: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let shower = TransitioningPresenter(segue: self)
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
    private class TransitioningPresenter: NSObject, UIViewControllerAnimatedTransitioning {

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
            segue.containerView.addSubview(toView)
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
    private class TransitioningDismisser: NSObject, UIViewControllerAnimatedTransitioning {

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
