//
//  SwiftMessages.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/1/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

private let globalInstance = SwiftMessages()

/**
 The `SwiftMessages` class provides the interface for showing and hiding messages.
 It behaves like a queue, only showing one message at a time. Message views that
 implement the `Identifiable` protocol (as `MessageView` does) will have duplicates removed.
 */
public class SwiftMessages: PresenterDelegate {

    public init() { }
    /**
     Specifies whether the message view is displayed at the top or bottom
     of the selected presentation container.
     */
    public enum PresentationStyle {

        /**
         Message view slides down from the top.
         */
        case Top

        /**
         Message view slides up from the bottom.
         */
        case Bottom
    }

    /**
     Specifies how the container for presenting the message view
     is selected.
     */
    public enum PresentationContext {

        /**
         Displays the message view under navigation bars and tab bars if an
         appropriate one is found. Otherwise, it is displayed in a new window
         at level `UIWindowLevelNormal`. Use this option to automatically display
         under bars, where applicable. Because this option involves a top-down
         search, an approrpiate context might not be found when the view controller
         heirarchy incorporates custom containers. If this is the case, the
         .ViewController option can provide a more targeted context.
         */
        case Automatic

        /**
         Displays the message in a new window at the specified window level. Use
         `UIWindowLevelNormal` to display under the status bar and `UIWindowLevelStatusBar`
         to display over. When displaying under the status bar, SwiftMessages automatically
         increases the top margins of any message view that adopts the `MarginInsetting`
         protocol (as `MessageView` does) to account for the status bar.
         */
        case Window(windowLevel: UIWindowLevel)

        /**
         Displays the message view under navigation bars and tab bars if an
         appropriate one is found using the given view controller as a starting
         point and searching up the parent view controller chain. Otherwise, it
         is displayed in the given view controller's view. This option can be used
         for targeted placement in a view controller heirarchy.
         */
        case ViewController(_: UIViewController)
    }

    /**
     Specifies the duration of the message view's time on screen before it is
     automatically hidden.
     */
    public enum Duration {

        /**
         Hide the message view after the default duration.
         */
        case Automatic

        /**
         Disables automatic hiding of the message view.
         */
        case Forever

        /**
         Hide the message view after the speficied number of seconds.

         - Parameter seconds: The number of seconds.
         */
        case Seconds(seconds: NSTimeInterval)
    }

    /**
     Specifies options for dimming the background behind the message view
     similar to a popover view controller.
     */
    public enum DimMode {

        /**
         Don't dim the background behind the message view.
         */
        case None

        /**
         Dim the background behind the message view a gray color.

         - Parameter interactive: Specifies whether or not tapping the
         dimmed area dismisses the message view.
         */
        case Gray(interactive: Bool)

        /**
         Dim the background behind the message view using the given color.
         SwiftMessages does not apply alpha transparency to the color, so any alpha
         must be baked into the `UIColor` instance.

         - Parameter color: The color of the dim view.
         - Parameter interactive: Specifies whether or not tapping the
         dimmed area dismisses the message view.
         */
        case Color(color: UIColor, interactive: Bool)
    }

    /**
     The `Config` struct specifies options for displaying a single message view. It is
     provided as an optional argument to one of the `MessageView.show()` methods.
     */
    public struct Config {

        public init() { }

        /**
         Specifies whether the message view is displayed at the top or bottom
         of the selected presentation container. The default is `.Top`.
         */
        public var presentationStyle = PresentationStyle.Top

        /**
         Specifies how the container for presenting the message view
         is selected. The default is `.Automatic`.
         */
        public var presentationContext = PresentationContext.Automatic

        /**
         Specifies the duration of the message view's time on screen before it is
         automatically hidden. The default is `.Automatic`.
         */
        public var duration = Duration.Automatic

        /**
         Specifies options for dimming the background behind the message view
         similar to a popover view controller. The default is `.None`.
         */
        public var dimMode = DimMode.None

        /**
         Specifies whether or not the interactive pan-to-hide gesture is enabled
         on the message view. For views that implement the `BackgroundViewable`
         protocol (as `MessageView` does), the pan gesture recognizer is installed
         in the `backgroundView`, which allows for card-style views with transparent
         margins that shouldn't be interactive. Otherwise, it is installed in
         the message view itself. The default is `true`.
         */
        public var interactiveHide = true

        /**
         Specifies the preferred status bar style when the view is displayed
         directly behind the status bar, such as when using `.Window`
         presentation context with a `UIWindowLevelNormal` window level
         and `.Top` presentation style. This option is useful if the message
         view has a background color that needs a different status bar style than
         the current one. The default is `.Default`.
         */
        public var preferredStatusBarStyle: UIStatusBarStyle?
    }

    /**
     Adds the given configuration and view to the message queue to be displayed.

     - Parameter config: The configuration options.
     - Parameter view: The view to be displayed.
     */
    public func show(config config: Config, view: UIView) {
        dispatch_async(syncQueue) { [weak self] in
            guard let strongSelf = self else { return }
            let presenter = Presenter(config: config, view: view, delegate: strongSelf)
            strongSelf.enqueue(presenter: presenter)
        }
    }

    /**
     Adds the given view to the message queue to be displayed
     with default configuration options.

     - Parameter config: The configuration options.
     - Parameter view: The view to be displayed.
     */
    public func show(view view: UIView) {
        show(config: Config(), view: view)
    }

    /// A block that returns an arbitrary view.
    public typealias ViewProvider = () -> UIView

    /**
     Adds the given configuration and view provider to the message queue to be displayed.

     The `viewProvider` block is guaranteed to be called on the main queue where
     it is safe to interact with `UIKit` components. This variant of `show()` is
     recommended when the message might be added from a background queue.

     - Parameter config: The configuration options.
     - Parameter viewProvider: A block that returns the view to be displayed.
     */
    public func show(config config: Config, viewProvider: ViewProvider) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let strongSelf = self else { return }
            let view = viewProvider()
            strongSelf.show(config: config, view: view)
        }
    }

    /**
     Adds the given view provider to the message queue to be displayed
     with default configuration options.

     The `viewProvider` block is guaranteed to be called on the main queue where
     it is safe to interact with `UIKit` components. This variant of `show()` is
     recommended when the message might be added from a background queue.

     - Parameter viewProvider: A block that returns the view to be displayed.
     */
    public func show(viewProvider viewProvider: ViewProvider) {
        show(config: Config(), viewProvider: viewProvider)
    }

    /**
     Hide the current message being displayed by animating it away.
     */
    public func hide() {
        dispatch_async(syncQueue) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.hideCurrent()
        }
    }

    /**
     Hide the current message, if there is one, by animating it away and
     clear the message queue.
     */
    public func hideAll() {
        dispatch_async(syncQueue) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.queue.removeAll()
            strongSelf.hideCurrent()
        }
    }

    /**
     Hide a message with the given `id`. If the specified message is
     currently being displayed, it will be animated away. Works with message
     views, such as `MessageView`, that implement the `Identifiable` protocol.
     - Parameter id: The identifier of the message to remove.
     */
    public func hide(id id: String) {
        dispatch_async(syncQueue) { [weak self] in
            guard let strongSelf = self else { return }
            if id == strongSelf.current?.id {
                strongSelf.hideCurrent()
            }
            strongSelf.queue = strongSelf.queue.filter { $0.id != id }
        }
    }

    /**
     Specifies the amount of time to pause between removing a message
     and showing the next. Default is 0.5 seconds.
     */
    public var pauseBetweenMessages: NSTimeInterval = 0.5

    let syncQueue = dispatch_queue_create("it.swiftkick.SwiftMessages", DISPATCH_QUEUE_SERIAL)
    var queue: [Presenter] = []
    var current: Presenter? = nil {
        didSet {
            if oldValue != nil {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(pauseBetweenMessages * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, syncQueue, { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.dequeueNext()
                })
            }
        }
    }

    func enqueue(presenter presenter: Presenter) {
        if let id = presenter.id {
            if current?.id == id { return }
            if queue.filter({ $0.id == id }).count > 0 { return }
        }
        queue.append(presenter)
        dequeueNext()
    }

    func dequeueNext() {
        guard self.current == nil else { return }
        guard queue.count > 0 else { return }
        let current = queue.removeFirst()
        self.current = current
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let strongSelf = self else { return }
            do {
                try current.show { completed in
                    guard let strongSelf = self else { return }
                    guard completed else {
                        dispatch_async(strongSelf.syncQueue, {
                            guard let strongSelf = self else { return }
                            strongSelf.hide(presenter: current)
                        })
                        return
                    }
                    strongSelf.queueAutoHide()
                }
            } catch {
                strongSelf.current = nil
            }
        }
    }

    func hideCurrent() {
        guard let current = current else { return }
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            current.hide { (completed) in
                guard completed else { return }
                guard let strongSelf = self else { return }
                dispatch_async(strongSelf.syncQueue, {
                    guard let strongSelf = self else { return }
                    strongSelf.current = nil
                })
            }
        }
    }

    private var autohideToken: AnyObject?

    private func queueAutoHide() {
        guard let current = current else { return }
        autohideToken = current
        if let pauseDuration = current.pauseDuration {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(pauseDuration * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, syncQueue, { [weak self] in
                guard let strongSelf = self else { return }
                // Make sure we've still got a green light to auto-hide.
                if strongSelf.autohideToken !== current { return }
                strongSelf.hide(presenter: current)
            })
        }
    }

    /*
     MARK: - PresenterDelegate
     */

    func hide(presenter presenter: Presenter) {
        dispatch_async(syncQueue) { [weak self] in
            guard let strongSelf = self else { return }
            if let current = strongSelf.current where presenter === current {
                strongSelf.hideCurrent()
            }
            strongSelf.queue = strongSelf.queue.filter { $0 !== presenter }
        }
    }

    func panStarted(presenter presenter: Presenter) {
        autohideToken = nil
    }

    func panEnded(presenter presenter: Presenter) {
        queueAutoHide()
    }
}

/**
 MARK: - Creating views from nibs

 This extension provides several convenience functions for instantiating views from nib files.
 SwiftMessages provides several default nib files in the Resources folder that can be
 drag-and-dropped into a project as a starting point and modified.
 */

extension SwiftMessages {

    /**
     Loads a nib file with the same name as the generic view type `T` and returns
     the first view found in the nib file with matching type `T`. For example, if
     the generic type is `MyView`, a nib file named `MyView.nib` is loaded and the
     first top-level view of type `MyView` is returned. The main bundle is searched
     first followed by the SwiftMessages bundle.

     - Parameter filesOwner: An optional files owner.

     - Throws: `Error.CannotLoadViewFromNib` if a view matching the
     generic type `T` is not found in the nib.

     - Returns: An instance of generic view type `T`.
     */
    public class func viewFromNib<T: UIView>(filesOwner: AnyObject = NSNull.init()) throws -> T {
        let name = T.description().componentsSeparatedByString(".").last
        assert(name != nil)
        let view: T = try internalViewFromNib(named: name!, bundle: nil, filesOwner: filesOwner)
        return view
    }

    /**
     Loads a nib file with specified name and returns the first view found in the  nib file
     with matching type `T`. The main bundle is searched first followed by the SwiftMessages bundle.

     - Parameter name: The name of the nib file (excluding the .xib extension).
     - Parameter filesOwner: An optional files owner.

     - Throws: `Error.CannotLoadViewFromNib` if a view matching the
     generic type `T` is not found in the nib.

     - Returns: An instance of generic view type `T`.
     */
    public class func viewFromNib<T: UIView>(named name: String, filesOwner: AnyObject = NSNull.init()) throws -> T {
        let view: T = try internalViewFromNib(named: name, bundle: nil, filesOwner: filesOwner)
        return view
    }

    /**
     Loads a nib file with specified name in the specified bundle and returns the
     first view found in the  nib file with matching type `T`.

     - Parameter name: The name of the nib file (excluding the .xib extension).
     - Parameter bundle: The name of the bundle containing the nib file.
     - Parameter filesOwner: An optional files owner.

     - Throws: `Error.CannotLoadViewFromNib` if a view matching the
     generic type `T` is not found in the nib.

     - Returns: An instance of generic view type `T`.
     */
    public class func viewFromNib<T: UIView>(named name: String, bundle: NSBundle, filesOwner: AnyObject = NSNull.init()) throws -> T {
        let view: T = try internalViewFromNib(named: name, bundle: bundle, filesOwner: filesOwner)
        return view
    }

    private class func internalViewFromNib<T: UIView>(named name: String, bundle: NSBundle? = nil, filesOwner: AnyObject = NSNull.init()) throws -> T {
        let resolvedBundle: NSBundle
        if let bundle = bundle {
            resolvedBundle = bundle
        } else {
            if NSBundle.mainBundle().pathForResource(name, ofType: "nib") != nil {
                resolvedBundle = NSBundle.mainBundle()
            } else {
                resolvedBundle = NSBundle.sm_frameworkBundle()
            }
        }
        let arrayOfViews = resolvedBundle.loadNibNamed(name, owner: filesOwner, options: nil)
        guard let view = arrayOfViews.flatMap({ $0 as? T }).first else { throw Error.CannotLoadViewFromNib(nibName: name) }
        return view
    }
}

/*
 MARK: - Static APIs

 This extension provides a shared instance of `SwiftMessages` and a static API wrapper around
 this instance for simplified syntax. For example, `SwiftMessages.show()` is equivalent
 to `SwiftMessages.sharedInstance.show()`.
 */

extension SwiftMessages {

    /**
     A default shared instance of `SwiftMessages`. The `SwiftMessages` class provides
     a set of static APIs that wrap calls to this instance. For example, `SwiftMessages.show()`
     is equivalent to `SwiftMessages.sharedInstance.show()`.
     */
    public static var sharedInstance: SwiftMessages {
        return globalInstance
    }

    public static func show(viewProvider viewProvider: ViewProvider) {
        globalInstance.show(viewProvider: viewProvider)
    }

    public static func show(config config: Config, viewProvider: ViewProvider) {
        globalInstance.show(config: config, viewProvider: viewProvider)
    }

    public static func show(view view: UIView) {
        globalInstance.show(view: view)
    }

    public static func show(config config: Config, view: UIView) {
        globalInstance.show(config: config, view: view)
    }

    public static func hide() {
        globalInstance.hide()
    }

    public static func hideAll() {
        globalInstance.hideAll()
    }

    public static func hide(id id: String) {
        globalInstance.hide(id: id)
    }

    public static var pauseBetweenMessages: NSTimeInterval {
        get {
            return globalInstance.pauseBetweenMessages
        }
        set {
            globalInstance.pauseBetweenMessages = newValue
        }
    }
}