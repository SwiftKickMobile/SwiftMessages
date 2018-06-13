//
//  StoryboardSegue.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 5/30/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit

/**
 A configurable `UIStoryboardSegue subclass that utilizes SwiftMessages to
 present a view controller modally. Several convenience classes are provided below,
 providing pre-defined configurations (e.g. `TopMessageViewSegue`), so you don't have
 to write any configuration code. However, if the pre-defined configurations aren't
 sufficient, you can further configure the segue in `prepare(for:sender:)` whether or not
 you use the convenience classes.

 This class can be used programatically by initializing an instance and calling `perform()`.
 To dismiss, just call `dismiss(animated:, completion:)` on the presenting view controller.
 There is no need to retain the instance of `StoryboardSegue` (it retains and releases itself).

 See the "View Controllers" selection in the Demo app.
 */
public class StoryboardSegue: UIStoryboardSegue {

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
     `SwiftMessages.show()`. This class is responsible for performing this installation,
     but any other configuration is up to the caller.
     */
    public var messageView = BaseView()

    /**
     Specifies how the view controller's view is installed into the
     containing message view.
     */
    public var containment: Containment = .content

    /**
     Specifies how much the view controller's view is inset from it's superview
     when installed by the segue. This value is passed to either `BaseView.installContentView(:insets:)`
     or `BaseView.installBackgroundView(:insets:)` depending on the value of `containment`.
     */
    public var containmentInsets: UIEdgeInsets = .zero

    // The presentation style to use. See the SwiftMessages.PresentationStyle documentation for details.
    public var presentationStyle: SwiftMessages.PresentationStyle {
        get { return messenger.defaultConfig.presentationStyle }
        set { messenger.defaultConfig.presentationStyle = newValue }
    }

    // The dim mode to use. See the SwiftMessages.DimMode documentation for details.
    public var dimMode: SwiftMessages.DimMode {
        get { return messenger.defaultConfig.dimMode}
        set { messenger.defaultConfig.dimMode = newValue }
    }

    private var messenger = SwiftMessages()
    private var selfRetainer: StoryboardSegue? = nil
    private lazy var hider = { return Hider(segue: self) }()
    private var configuredLayout: Layout?

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
 This class is intended for use with Interface Builder. Reference as `StoryboardSegue` in code.
*/
public class TopMessageViewSegue: StoryboardSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        presentationStyle = .top
        configure(layout: .messageView)
    }
}

/**
 A convenience class that presents a top message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `StoryboardSegue` in code.
*/
public class TopCardViewSegue: StoryboardSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        presentationStyle = .top
        configure(layout: .cardView)
    }
}

/**
 A convenience class that presents a bottom message using the standard message view layout.
 This class is intended for use with Interface Builder. Reference as `StoryboardSegue` in code.
 */
public class BottomMessageViewSegue: StoryboardSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        presentationStyle = .bottom
        configure(layout: .messageView)
    }
}

/**
 A convenience class that presents a bottom message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `StoryboardSegue` in code.
 */
public class BottomCardViewSegue: StoryboardSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        presentationStyle = .bottom
        configure(layout: .cardView)
    }
}

/**
 A convenience class that presents centered message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `StoryboardSegue` in code.
 */
public class CenteredViewSegue: StoryboardSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        presentationStyle = .center
        configure(layout: .centeredView)
    }
}

extension StoryboardSegue {
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
        configuredLayout = layout
    }
}

extension StoryboardSegue: UIViewControllerTransitioningDelegate {
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

extension StoryboardSegue {
    private class Shower: NSObject, UIViewControllerAnimatedTransitioning {

        fileprivate private(set) var completeTransition: ((_: Bool) -> Void)?
        private weak var segue: StoryboardSegue?

        fileprivate init(segue: StoryboardSegue) {
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

extension StoryboardSegue {
    private class Hider: NSObject, UIViewControllerAnimatedTransitioning {

        fileprivate private(set) var completeTransition: ((_: Bool) -> Void)?
        private weak var segue: StoryboardSegue?

        fileprivate init(segue: StoryboardSegue) {
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
