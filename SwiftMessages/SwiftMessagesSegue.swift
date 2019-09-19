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
 2. SwiftMessagesSegue provides static default view controller sizing based on device.
    However, it is recommended that you specify sizing appropriate for your content using
    one of the following methods.
    1. Define sufficient width and height constraints in your view controller.
    2. Set `preferredContentSize` (a.k.a "Use Preferred Explicit Size" in Interface Builder's
       attribute inspector). Zeros are ignored, e.g. `CGSize(width: 0, height: 350)` only
       affects the height.
    3. Add explicit width and/or height constraints to `segue.messageView.backgroundView`.
    Note that `Layout.topMessage` and `Layout.bottomMessage` are always full screen width.
    For other layouts, the there is a maximum 500pt width on iPad (regular horizontal size class)
    at 950 priority, which can be overridden by adding higher-priority constraints.
 
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
    
    // duration
    public var duration: SwiftMessages.Duration {
        get { return messenger.defaultConfig.duration}
        set { messenger.defaultConfig.duration = newValue }
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
    public var containerView: CornerRoundingView = CornerRoundingView()

    /**
     Specifies how the view controller's view is installed into the
     containing message view. See `Containment` for details.
     */
    public var containment: Containment = .content

    /**
     Supply an instance of `KeyboardTrackingView` to have the message view avoid the keyboard.
     */
    public var keyboardTrackingView: KeyboardTrackingView? {
        get {
            return messenger.defaultConfig.keyboardTrackingView
        }
        set {
            messenger.defaultConfig.keyboardTrackingView = newValue
        }
    }

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
            containment = .background
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
            toView.translatesAutoresizingMaskIntoConstraints = false
            segue.containerView.addSubview(toView)
            segue.containerView.topAnchor.constraint(equalTo: toView.topAnchor).isActive = true
            segue.containerView.bottomAnchor.constraint(equalTo: toView.bottomAnchor).isActive = true
            segue.containerView.leadingAnchor.constraint(equalTo: toView.leadingAnchor).isActive = true
            segue.containerView.trailingAnchor.constraint(equalTo: toView.trailingAnchor).isActive = true
            // Install the `toView` into the message view.
            switch segue.containment {
            case .content:
                segue.messageView.installContentView(segue.containerView)
            case .background:
                segue.messageView.installBackgroundView(segue.containerView)
            case .backgroundVertical:
                segue.messageView.installBackgroundVerticalView(segue.containerView)
            }
            let toVC = transitionContext.viewController(forKey: .to)
            if let preferredHeight = toVC?.preferredContentSize.height,
                preferredHeight > 0 {
                segue.containerView.heightAnchor.constraint(equalToConstant: preferredHeight).with(priority: UILayoutPriority(rawValue: 950)).isActive = true
            }
            if let preferredWidth = toVC?.preferredContentSize.width,
                preferredWidth > 0 {
                segue.containerView.widthAnchor.constraint(equalToConstant: preferredWidth).with(priority: UILayoutPriority(rawValue: 950)).isActive = true
            }
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
