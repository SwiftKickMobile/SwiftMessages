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
open class SwiftMessages: PresenterDelegate {
    
    /**
     Specifies whether the message view is displayed at the top or bottom
     of the selected presentation container.
    */
    public enum PresentationStyle {
        
        /**
         Message view slides down from the top.
        */
        case top

        /**
         Message view slides up from the bottom.
         */
        case bottom
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
        case automatic

        /**
         Displays the message in a new window at the specified window level. Use
         `UIWindowLevelNormal` to display under the status bar and `UIWindowLevelStatusBar`
         to display over. When displaying under the status bar, SwiftMessages automatically
         increases the top margins of any message view that adopts the `MarginInsetting`
         protocol (as `MessageView` does) to account for the status bar.
        */
        case window(windowLevel: UIWindowLevel)
        
        /**
         Displays the message view under navigation bars and tab bars if an
         appropriate one is found using the given view controller as a starting
         point and searching up the parent view controller chain. Otherwise, it
         is displayed in the given view controller's view. This option can be used
         for targeted placement in a view controller heirarchy.
        */
        case viewController(_: UIViewController)
        
        /**
         Displays the message view in the given container view.
         */
        case view(_: UIView)
    }
    
    /**
     Specifies the duration of the message view's time on screen before it is
     automatically hidden.
    */
    public enum Duration {
        
        /**
         Hide the message view after the default duration.
        */
        case automatic
        
        /**
         Disables automatic hiding of the message view.
        */
        case forever
        
        /**
         Hide the message view after the speficied number of seconds.
         
         - Parameter seconds: The number of seconds.
        */
        case seconds(seconds: TimeInterval)

        /**
         The `indefinite` option is similar to `forever` in the sense that
         the message view will not be automatically hidden. However, it
         provides two options that can be useful in some scenarios:
         
            - `delay`: wait the specified time interval before displaying
                       the message. If you hide the message during the delay
                       interval by calling either `hideAll()` or `hide(id:)`,
                       the message will not be displayed. This is not the case for
                       `hide()` because it only acts on a visible message. Messages
                       shown during another message's delay window are displayed first.
            - `minimum`: if the message is displayed, ensure that it is displayed
                         for a minimum time interval. If you explicitly hide the
                         during this interval, the message will be hidden at the
                         end of the interval.

         This option is useful for displaying a message when a process is taking
         too long but you don't want to display the message if the process completes
         in a reasonable amount of time. The value `indefinite(delay: 0, minimum: 0)`
         is equivalent to `forever`.
         
         For example, if a URL load is expected to complete in 2 seconds, you may use
         the value `indefinite(delay: 2, minimum 1)` to ensure that the message will not
         be displayed in most cases, but will be displayed for at least 1 second if
         the operation takes longer than 2 seconds. By specifying a minimum duration,
         you can avoid hiding the message too fast if the operation finishes right
         after the delay interval.
        */
        case indefinite(delay: TimeInterval, minimum: TimeInterval)
    }
    
    /**
     Specifies options for dimming the background behind the message view
     similar to a popover view controller.
    */
    public enum DimMode {
        
        /**
         Don't dim the background behind the message view.
        */
        case none

        /**
         Dim the background behind the message view a gray color.
         
         - `interactive`: Specifies whether or not tapping the
                          dimmed area dismisses the message view.
         */
        case gray(interactive: Bool)

        /**
         Dim the background behind the message view using the given color.
         SwiftMessages does not apply alpha transparency to the color, so any alpha
         must be baked into the `UIColor` instance.
         
         - `color`: The color of the dim view.
         - `interactive`: Specifies whether or not tapping the
                          dimmed area dismisses the message view.
         */
        case color(color: UIColor, interactive: Bool)
    }

    /**
     Specifies events in the message lifecycle.
    */
    public enum Event {
        case willShow
        case didShow
        case willHide
        case didHide
    }
    
    /**
     A closure that takes an `Event` as an argument.
     */
    public typealias EventListener = (Event) -> Void
    
    /**
     The `Config` struct specifies options for displaying a single message view. It is
     provided as an optional argument to one of the `MessageView.show()` methods.
     */
    public struct Config {
        
        public init() {}
        
        /**
         Specifies whether the message view is displayed at the top or bottom
         of the selected presentation container. The default is `.Top`.
         */
        public var presentationStyle = PresentationStyle.top

        /**
         Specifies how the container for presenting the message view
         is selected. The default is `.Automatic`.
         */
        public var presentationContext = PresentationContext.automatic

        /**
         Specifies the duration of the message view's time on screen before it is
         automatically hidden. The default is `.Automatic`.
         */
        public var duration = Duration.automatic
        
        /**
         Specifies options for dimming the background behind the message view
         similar to a popover view controller. The default is `.None`.
         */
        public var dimMode = DimMode.none
        
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
        
        /**
         If a view controller is created to host the message view, should the view 
         controller auto rotate?  The default is 'true', meaning it should auto
         rotate.
         */
        public var shouldAutorotate = true

        /**
         Specified whether or not duplicate `Identifiable` messages are ignored.
         The default is `true`.
        */
        public var ignoreDuplicates = true
        
        /**
         Specifies an optional array of event listeners.
        */
        public var eventListeners: [EventListener] = []
        
        /**
         Specifies that in cases where the message is displayed in its own window,
         such as with `.window` presentation context, the window should become
         the key window. This option should only be used if the message view
         needs to receive non-touch events, such as keyboard input. From Apple's
         documentation https://developer.apple.com/reference/uikit/uiwindow:
         
         > Whereas touch events are delivered to the window where they occurred,
         > events that do not have a relevant coordinate value are delivered to
         > the key window. Only one window at a time can be the key window, and
         > you can use a window’s keyWindow property to determine its status.
         > Most of the time, your app’s main window is the key window, but UIKit
         > may designate a different window as needed.
         */
        public var becomeKeyWindow: Bool?
    }
    
    /**
     Not much to say here.
     */
    public init() {}
    
    /**
     Adds the given configuration and view to the message queue to be displayed.
     
     - Parameter config: The configuration options.
     - Parameter view: The view to be displayed.
     */
    open func show(config: Config, view: UIView) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let presenter = Presenter(config: config, view: view, delegate: strongSelf)
            strongSelf.syncQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.enqueue(presenter: presenter)
            }
        }
    }
    
    /**
     Adds the given view to the message queue to be displayed
     with default configuration options.
     
     - Parameter config: The configuration options.
     - Parameter view: The view to be displayed.
     */
    public func show(view: UIView) {
        show(config: defaultConfig, view: view)
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
    open func show(config: Config, viewProvider: @escaping ViewProvider) {
        DispatchQueue.main.async { [weak self] in
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
    public func show(viewProvider: @escaping ViewProvider) {
        show(config: defaultConfig, viewProvider: viewProvider)
    }
    
    /**
     Hide the current message being displayed by animating it away.
     */
    open func hide() {
        syncQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.hideCurrent()
        }
    }

    /**
     Hide the current message, if there is one, by animating it away and
     clear the message queue.
     */
    open func hideAll() {
        syncQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.queue.removeAll()
            strongSelf.delays.ids.removeAll()
            strongSelf.hideCurrent()
        }
    }

    /**
     Hide a message with the given `id`. If the specified message is
     currently being displayed, it will be animated away. Works with message
     views, such as `MessageView`, that implement the `Identifiable` protocol.
     - Parameter id: The identifier of the message to remove.
     */
    open func hide(id: String) {
        syncQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            if id == strongSelf.current?.id {
                strongSelf.hideCurrent()
            }
            strongSelf.queue = strongSelf.queue.filter { $0.id != id }
            strongSelf.delays.ids.remove(id)
        }
    }
    
    /**
     Specifies the default configuration to use when calling the variants of
     `show()` that don't take a `config` argument or as a base for custom configs.
     */
    public var defaultConfig = Config()

    /**
     Specifies the amount of time to pause between removing a message
     and showing the next. Default is 0.5 seconds.
     */
    open var pauseBetweenMessages: TimeInterval = 0.5

    /// Type for keeping track of delayed presentations
    class Delays {

        var ids = Set<String>()

        func add(presenter: Presenter) {
            guard let id = presenter.id else { return }
            ids.insert(id)
        }

        @discardableResult
        func remove(presenter: Presenter) -> Bool {
            guard let id = presenter.id, ids.contains(id) else { return false }
            ids.remove(id)
            return true
        }
    }

    let syncQueue = DispatchQueue(label: "it.swiftkick.SwiftMessages", attributes: [])
    var queue: [Presenter] = []
    var delays = Delays()
    var current: Presenter? = nil {
        didSet {
            if oldValue != nil {
                let delayTime = DispatchTime.now() + pauseBetweenMessages
                syncQueue.asyncAfter(deadline: delayTime, execute: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.dequeueNext()
                })
            }
        }
    }

    func enqueue(presenter: Presenter) {
        if presenter.config.ignoreDuplicates, let id = presenter.id {
            if current?.id == id && current?.isHiding == false { return }
            if queue.filter({ $0.id == id }).count > 0 { return }
        }
        func doEnqueue() {
            queue.append(presenter)
            dequeueNext()
        }
        if let delay = presenter.delayShow {
            delays.add(presenter: presenter)
            syncQueue.asyncAfter(deadline: .now() + delay) {
                // Don't enqueue if the view has been hidden during the delay window.
                if !self.delays.remove(presenter: presenter) { return }
                doEnqueue()
            }
        } else {
            doEnqueue()
        }
    }
    
    func dequeueNext() {
        guard self.current == nil else { return }
        guard queue.count > 0 else { return }
        let current = queue.removeFirst()
        self.current = current
        current.showDate = Date()
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            do {
                try current.show { completed in
                    guard let strongSelf = self else { return }
                    guard completed else {
                        strongSelf.syncQueue.async(execute: {
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
        let delay = current.delayHide ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            current.hide { (completed) in
                guard completed else { return }
                guard let strongSelf = self else { return }
                strongSelf.syncQueue.async(execute: {
                    guard let strongSelf = self else { return }
                    strongSelf.current = nil
                })
            }
        }
    }
    
    fileprivate weak var autohideToken: AnyObject?
    
    fileprivate func queueAutoHide() {
        guard let current = current else { return }
        autohideToken = current
        if let pauseDuration = current.pauseDuration {
            let delayTime = DispatchTime.now() + pauseDuration
            syncQueue.asyncAfter(deadline: delayTime, execute: { [weak self, weak current] in
                guard let strongSelf = self, let current = current else { return }
                // Make sure we've still got a green light to auto-hide.
                if strongSelf.autohideToken !== current { return }
                strongSelf.hide(presenter: current)
            })
        }
    }
    
    /*
     MARK: - PresenterDelegate
     */
    
    func hide(presenter: Presenter) {
        syncQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            if let current = strongSelf.current, presenter === current {
                strongSelf.hideCurrent()
            }
            strongSelf.queue = strongSelf.queue.filter { $0 !== presenter }
            strongSelf.delays.remove(presenter: presenter)
        }
    }
    
    func panStarted(presenter: Presenter) {
        autohideToken = nil
    }
    
    func panEnded(presenter: Presenter) {
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
    public class func viewFromNib<T: UIView>(_ filesOwner: AnyObject = NSNull.init()) throws -> T {
        let name = T.description().components(separatedBy: ".").last
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
    public class func viewFromNib<T: UIView>(named name: String, bundle: Bundle, filesOwner: AnyObject = NSNull.init()) throws -> T {
        let view: T = try internalViewFromNib(named: name, bundle: bundle, filesOwner: filesOwner)
        return view
    }
    
    fileprivate class func internalViewFromNib<T: UIView>(named name: String, bundle: Bundle? = nil, filesOwner: AnyObject = NSNull.init()) throws -> T {
        let resolvedBundle: Bundle
        if let bundle = bundle {
            resolvedBundle = bundle
        } else {
            if Bundle.main.path(forResource: name, ofType: "nib") != nil {
                resolvedBundle = Bundle.main
            } else {
                resolvedBundle = Bundle.sm_frameworkBundle()
            }
        }
        let arrayOfViews = resolvedBundle.loadNibNamed(name, owner: filesOwner, options: nil) ?? []
        guard let view = arrayOfViews.flatMap( { $0 as? T} ).first else { throw SwiftMessagesError.cannotLoadViewFromNib(nibName: name) }
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
    
    public static func show(viewProvider: @escaping ViewProvider) {
        globalInstance.show(viewProvider: viewProvider)
    }
    
    public static func show(config: Config, viewProvider: @escaping ViewProvider) {
        globalInstance.show(config: config, viewProvider: viewProvider)
    }
    
    public static func show(view: UIView) {
        globalInstance.show(view: view)
    }

    public static func show(config: Config, view: UIView) {
        globalInstance.show(config: config, view: view)
    }

    public static func hide() {
        globalInstance.hide()
    }
    
    public static func hideAll() {
        globalInstance.hideAll()
    }
    
    public static func hide(id: String) {
        globalInstance.hide(id: id)
    }
    
    public static var defaultConfig: Config {
        get {
            return globalInstance.defaultConfig
        }
        set {
            globalInstance.defaultConfig = newValue
        }
    }
    
    public static var pauseBetweenMessages: TimeInterval {
        get {
            return globalInstance.pauseBetweenMessages
        }
        set {
            globalInstance.pauseBetweenMessages = newValue
        }
    }
}
