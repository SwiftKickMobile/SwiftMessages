//
//  SwiftMessagesSegue.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 5/30/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit

/**
 Take advantage of SwiftMessages directly from within Interface Builder to present your modal
 view controllers! Utilize many of SwiftMessage's bells and whistles — animations,
 layouts, background dimming, etc. — for free with a simple control-drag between view
 controllers.

 `SwiftMessagesSegue` is a configurable subclass of `UIStoryboardSegue` that utilizes
 SwiftMessages to present and dismiss modal view controllers. `SwiftMessagesSegue` performs
 these transitions by becoming your view controller's `transitioningDelegate`, calling
 SwiftMessage's `show()` and `hide()` under the hood.

 `SwiftMessagesSegue` is easy to use: just select "swift messages" Manual Segue type when
 control-dragging a new segue in IB. If you need to set any of the `SwiftMessagesSegue`
 configuration options, you can do so in `prepare(for:sender:)` (ask Apple to
 support `IBInspectable` for segues!) or define your own self-configuring subclass.

 A number of pre-defined configurations are provided for your convenience in the form of
 self-configuring subclasses: `TopMessageViewSegue`, `BottomMessageViewSegue`, `TopCardViewSegue`,
 `BottomCardViewSegue`, and `CenteredViewSegue`. You'll see these in IB as Manual Segue types:
 "top message view", "bottom message view", "top card view", "bottom card view", and "centered view"
 (more coming soon).

 The `SwiftMessagesSegue` class can alternatively be used programatically without an associated IB
 segue. Just create an instance in the presenting view controller and call `perform()`:

     let destinationVC = ... // make a reference to a destination view controller
     let segue = BottomCardViewSegue(identifier: nil, source: self, destination: destinationVC)
     ... // do any configuration here
     segue.perform()

 To dismiss, just call the normal API:

     dismiss(animated: true, completion: nil)

 It is not necessary to retain `segue` because it retains itself until dismissal. However, you can
 retain it if you plan to `perform()` more than once.

 Some additional things to note:
 1. Your view controller's view will be embedded in a `SwiftMessages.BaseView` in order to
    utilize some SwiftMessages features. This view can be accessed and configured via the
    `SwiftMessagesSegue.messageView` property.
 2. Some view controller's views do not define a good `intrinsicContentSize`, which
    SwiftMessages generally relies on to establish the message view's height. A typical example
    is `UINavigationController`. As a workaround, you can specify an explicit height in your
    configuration:

     segue.messageView.preferredHeight = 300

 See the "View Controllers" selection in the Demo app for examples.
 */
public class SwiftMessagesSegue: UIStoryboardSegue {

    /**
     Specifies one of the pre-defined configurations, mirroring a subset of `MessageView.Layout`.
     */
    public enum Layout {

        /// The standard message view layout.
        case messageView

        /// A floating card-style view with rounded corners.
        case cardView

        /// A floating card-style view typically used with `.center` presentation style.
        case centeredView
    }

    /**
     Specifies how the view controller's view is installed into the
     containing message view.
     */
    public enum Containment {

        /**
         The view controller's view is installed using `BaseView.installContentView(:insets:)`.
         Use this option when the message view itself should provide a visible background and the
         view controller's view should be inset from the margins (and safe areas) but the background
         should span the full width and not avoid margins (or safe areas).
         See that method's documentation for details.
         */
        case content

        /**
         The view controller's view is installed using `BaseView.installBackgroundView(:insets:)`.
         Use this option when the message view's background should be transparent because the view
         controller's view is providing the visible background, which should be inset from the margins
         (and safe areas). See that method's documentation for details.
         */
        case background
    }

    /**
     The view that the view controller's view is installed into and displayed using
     `SwiftMessages.show()`. This class is responsible for performing the installation,
     but any other optional configuration of `messageView` is up to the caller.

     Note that some view controller's views do not define a good `intrinsicContentSize`, which
     SwiftMessages generally relies on to establish the message view's height. A typical example
     is `UINavigationController`. As a workaround, you can specify an explicit height in your
     configuration using `StoryboardSegue.messageView.preferredHeight`.
     */
    public var messageView = BaseView()

    /**
     Specifies how the view controller's view is installed into the
     containing message view.
     */
    public var containment: Containment = .content

    /**
     Specifies how much the view controller's view is inset from its superview
     when installed by the segue. This value is passed to either `BaseView.installContentView(:insets:)`
     or `BaseView.installBackgroundView(:insets:)` depending on the value of `containment`.
     */
    public var containmentInsets: UIEdgeInsets = .zero

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

    private var messenger = SwiftMessages()
    private var selfRetainer: SwiftMessagesSegue? = nil
    private lazy var hider = { return Hider(segue: self) }()

    private lazy var presenter = {
        return Presenter(config: messenger.defaultConfig, view: messageView, delegate: messenger)
    }()

    override public func perform() {
        selfRetainer = self
        destination.modalPresentationStyle = .overFullScreen
        destination.transitioningDelegate = self
        source.present(destination, animated: true, completion: nil)
    }

    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        dimMode = .gray(interactive: true)
        messenger.defaultConfig.interactiveHide = false
        messenger.defaultConfig.duration = .forever
    }
}

/**
 A convenience class that presents a top message using the standard message view layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
*/
public class TopMessageViewSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        presentationStyle = .top
        configure(layout: .messageView)
    }
}

/**
 A convenience class that presents a top message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
*/
public class TopCardViewSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        presentationStyle = .top
        configure(layout: .cardView)
    }
}

/**
 A convenience class that presents a bottom message using the standard message view layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class BottomMessageViewSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        presentationStyle = .bottom
        configure(layout: .messageView)
    }
}

/**
 A convenience class that presents a bottom message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class BottomCardViewSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        presentationStyle = .bottom
        configure(layout: .cardView)
    }
}

/**
 A convenience class that presents centered message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class CenteredViewSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        presentationStyle = .center
        configure(layout: .centeredView)
    }
}

extension SwiftMessagesSegue {
    public func configure(layout: Layout) {
        let layer = destination.view.layer
        switch layout {
        case .messageView:
            messageView.bounceAnimationOffset = 5
            messageView.statusBarOffset = 8
            messageView.safeAreaTopOffset = -8
            messageView.safeAreaBottomOffset = -18
            containment = .content
            containmentInsets = .zero
            layer.cornerRadius = 0
            messageView.configureDropShadow()
        case .cardView:
            messageView.bounceAnimationOffset = 0
            messageView.statusBarOffset = 10
            messageView.safeAreaTopOffset = -8
            messageView.safeAreaBottomOffset = -20
            containment = .background
            containmentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layer.cornerRadius = 10
            layer.masksToBounds = true
            messageView.configureDropShadow()
        case .centeredView:
            messageView.bounceAnimationOffset = 0
            messageView.statusBarOffset = 10
            messageView.safeAreaTopOffset = -8
            messageView.safeAreaBottomOffset = -20
            containmentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layer.cornerRadius = 10
            layer.masksToBounds = true
            messageView.configureDropShadow()
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
                self.hider.completeTransition?(true)
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
            completeTransition = transitionContext.completeTransition
            let transitionContainer = transitionContext.containerView
            switch segue.containment {
            case .content:
                segue.messageView.installContentView(toView, insets: segue.containmentInsets)
            case .background:
                segue.messageView.installBackgroundView(toView, insets: segue.containmentInsets)
            }
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
