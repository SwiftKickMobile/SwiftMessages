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
 adopt the `Identifiable` protocol (as `MessageView` does) will have duplicates removed.
 */
@MainActor
open class SwiftMessages {
    
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

        /**
         Message view fades into the center.
         */
        case center

        /**
         User-defined animation
        */
        case custom(animator: Animator)
    }

    /**
     Specifies how the container for presenting the message view
     is selected.
    */
    public enum PresentationContext {
        
        /**
         Displays the message view under navigation bars and tab bars if an
         appropriate one is found. Otherwise, it is displayed in a new window
         at level `UIWindow.Level.normal`. Use this option to automatically display
         under bars, where applicable. Because this option involves a top-down
         search, an appropriate context might not be found when the view controller
         hierarchy incorporates custom containers. If this is the case, the
         .ViewController option can provide a more targeted context.
        */
        case automatic

        /**
         Displays the message in a new window at the specified window level.
         SwiftMessages automatically increases the top margins of any message
         view that adopts the `MarginInsetting` protocol (as `MessageView` does)
         to account for the status bar. As of iOS 13, windows can no longer cover the
         status bar. The only alternative is to set `Config.prefersStatusBarHidden = true`
         to hide it.
        */
        case window(windowLevel: UIWindow.Level)

        /**
         Displays the message in a new window, at the specified window level,
         in the specified window scene. SwiftMessages automatically increases the top margins
         of any message view that adopts the `MarginInsetting` protocol (as `MessageView` does)
         to account for the status bar. As of iOS 13, windows can no longer cover the
         status bar. The only alternative is to set `Config.prefersStatusBarHidden = true`
         to hide it. The `WindowScene` protocol works around the change in Xcode 13 that prevents
         using `@availability` attribute with `enum` cases containing associated values.
        */
        case windowScene(_: WindowScene, windowLevel: UIWindow.Level)

        /**
         Displays the message view under navigation bars and tab bars if an
         appropriate one is found using the given view controller as a starting
         point and searching up the parent view controller chain. Otherwise, it
         is displayed in the given view controller's view. This option can be used
         for targeted placement in a view controller hierarchy.
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
     Specifies notification's haptic feedback to be used on `MessageView` display
    */

    /**
     Specifies an optional haptic feedback to be used on `MessageView` display
    */
    public enum Haptic {
        case success
        case warning
        case error
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

        /**
         Dim the background behind the message view using a blur effect with
         the given style

         - `style`: The blur effect style to use
         - `alpha`: The alpha level of the blur
         - `interactive`: Specifies whether or not tapping the
         dimmed area dismisses the message view.
         */
        case blur(style: UIBlurEffect.Style, alpha: CGFloat, interactive: Bool)

        public var interactive: Bool {
            switch self {
            case .gray(let interactive):
                return interactive
            case .color(_, let interactive):
                return interactive
            case .blur (_, _, let interactive):
                return interactive
            case .none:
                return false
            }
        }

        public var modal: Bool {
            switch self {
            case .gray, .color, .blur:
                return true
            case .none:
                return false
            }
        }
    }

    /**
     Specifies events in the message lifecycle.
    */
    public enum Event {
        case willShow(UIView)
        case didShow(UIView)
        case willHide(UIView)
        case didHide(UIView)

        public var view: UIView {
            switch self {
            case .willShow(let view): return view
            case .didShow(let view): return view
            case .willHide(let view): return view
            case .didHide(let view): return view
            }
        }

        public var id: String? {
            return (view as? Identifiable)?.id
        }
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
         Specifies notification's haptic feedback to be played on `MessageView` display.
         No default value is provided.
         */
        public var haptic: Haptic? = nil
        
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
         Specifies the preferred status bar style when the view is being
         displayed in a window. This can be useful when the view is being
         displayed behind the status bar and the message view has a background
         color that needs a different status bar style than the current one.
         The default is `nil`.
         */
        public var preferredStatusBarStyle: UIStatusBarStyle?

        /**
         Specifies the preferred status bar visibility when the view is being
         displayed in a window. As of iOS 13, windows can no longer cover the
         status bar. The only alternative is to hide the status bar by setting
         this options to `true`. Default is `nil`.
         */
        public var prefersStatusBarHidden: Bool?

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

        /**
         The `dimMode` background will use this accessibility
         label, e.g. "dismiss" when the `interactive` option is used.
        */
        public var dimModeAccessibilityLabel: String = "dismiss"

        /**
         The user interface style to use when SwiftMessages displays a message its own window.
         Use with apps that don't support dark mode to prevent messages from adopting the
         system's interface style.
        */
        @available(iOS 13, *)
        public var overrideUserInterfaceStyle: UIUserInterfaceStyle {
            // Note that this is modelled as a computed property because
            // Swift doesn't allow `@available` with stored properties.
            get {
                guard let rawValue = overrideUserInterfaceStyleRawValue else { return .unspecified }
                return UIUserInterfaceStyle(rawValue: rawValue) ?? .unspecified
            }
            set {
                overrideUserInterfaceStyleRawValue = newValue.rawValue
            }
        }
        private var overrideUserInterfaceStyleRawValue: Int?

        /**
         If specified, SwiftMessages calls this closure when an instance of
         `WindowViewController` is needed. Use this if you need to supply a custom subclass
         of `WindowViewController`.
         */
        public var windowViewController: ((_ config: SwiftMessages.Config) -> WindowViewController)?

        /**
         Supply an instance of `KeyboardTrackingView` to have the message view avoid the keyboard.
         */
        public var keyboardTrackingView: KeyboardTrackingView?
        
        /**
         Specify a positive or negative priority to influence the position of a message in the queue based on it's relative priority.
         */
        public var priority: Int = 0
    }
    
    /**
     Not much to say here.
     */
    nonisolated public init() {}

    /**
     Adds the given configuration and view to the message queue to be displayed.
     
     - Parameter config: The configuration options.
     - Parameter view: The view to be displayed.
     */
    open func show(config: Config, view: UIView) {
        let presenter = Presenter(config: config, view: view, delegate: self)
        enqueue(presenter: presenter)
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
    nonisolated open func show(config: Config, viewProvider: @escaping ViewProvider) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let view = viewProvider()
            self.show(config: config, view: view)
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
    open func hide(animated: Bool = true) {
        hideCurrent(animated: animated)
    }

    /**
     Hide the current message, if there is one, by animating it away and
     clear the message queue.
     */
    open func hideAll() {
        queue.removeAll()
        delays.removeAll()
        counts.removeAll()
        hideCurrent()
    }

    /**
     Hide a message with the given `id`. If the specified message is
     currently being displayed, it will be animated away. Works with message
     views, such as `MessageView`, that adopt the `Identifiable` protocol.
     - Parameter id: The identifier of the message to remove.
     */
    open func hide(id: String) {
        if id == _current?.id {
            hideCurrent()
        }
        queue = queue.filter { $0.id != id }
        delays.remove(id: id)
        counts[id] = nil
    }

    /**
     Hide the message when the number of calls to show() and hideCounted(id:) for a
     given message ID are equal. This can be useful for messages that may be
     shown from  multiple code paths to ensure that all paths are ready to hide.
     */
    open func hideCounted(id: String) {
        if let count = counts[id] {
            if count < 2 {
                counts[id] = nil
            } else {
                counts[id] = count - 1
                return
            }
        }
        if id == _current?.id {
            hideCurrent()
        }
        queue = queue.filter { $0.id != id }
        delays.remove(id: id)
    }

    /**
     Get the count of a message with the given ID (see `hideCounted(id:)`)
     */
    public func count(id: String) -> Int {
        return counts[id] ?? 0
    }

    /**
     Explicitly set the count of a message with the given ID (see `hideCounted(id:)`).
     Not sure if there's a use case for this, but why not?!
     */
    public func set(count: Int, for id: String) {
        guard counts[id] != nil else { return }
        return counts[id] = count
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
    @MainActor
    fileprivate class Delays {

        fileprivate func add(presenter: Presenter) {
            presenters.insert(presenter)
        }

        @discardableResult
        fileprivate func remove(presenter: Presenter) -> Bool {
            guard presenters.contains(presenter) else { return false }
            presenters.remove(presenter)
            return true
        }

        fileprivate func remove(id: String) {
            presenters = presenters.filter { $0.id != id }
        }

        fileprivate func removeAll() {
            presenters.removeAll()
        }

        private var presenters = Set<Presenter>()
    }

    func show(presenter: Presenter) {
        enqueue(presenter: presenter)
    }

    fileprivate var queue: [Presenter] = []
    fileprivate var delays = Delays()
    fileprivate var counts: [String : Int] = [:]
    fileprivate var _current: Presenter? = nil {
        didSet {
            if oldValue != nil {
                Task { [weak self] in
                    try? await Task.sleep(seconds: self?.pauseBetweenMessages ?? 0)
                    self?.dequeueNext()
                }
            }
        }
    }

    fileprivate func enqueue(presenter: Presenter) {
        if presenter.config.ignoreDuplicates {
            counts[presenter.id] = (counts[presenter.id] ?? 0) + 1
            if let _current,
                _current.id == presenter.id,
               !_current.isHiding,
               !_current.isOrphaned { return }
            if queue.filter({ $0.id == presenter.id }).count > 0 { return }
        }
        func doEnqueue() {
            queue.append(presenter)
            dequeueNext()
        }
        if let delay = presenter.delayShow {
            delays.add(presenter: presenter)
            Task { [weak self] in
                try? await Task.sleep(seconds: delay)
                // Don't enqueue if the view has been hidden during the delay window.
                guard let self, self.delays.remove(presenter: presenter) else { return }
                doEnqueue()
            }
        } else {
            doEnqueue()
        }
    }
    
    fileprivate func dequeueNext() {
        guard queue.count > 0 else { return }
        if let _current, !_current.isOrphaned { return }
        // Sort by priority
        queue = queue.sorted { left, right in
            left.config.priority > right.config.priority
        }
        let current = queue.removeFirst()
        self._current = current
        // Set `autohideToken` before the animation starts in case
        // the dismiss gesture begins before we've queued the autohide
        // block on animation completion.
        self.autohideToken = current
        current.showDate = CACurrentMediaTime()
        do {
            try current.show { [weak self] completed in
                guard let self else { return }
                guard completed else {
                    self.internalHide(presenter: current)
                    return
                }
                if current === self.autohideToken {
                    self.queueAutoHide()
                }
            }
        } catch {
            _current = nil
        }
    }

    fileprivate func internalHide(presenter: Presenter) {
        if presenter == _current {
            hideCurrent()
        } else {
            queue = queue.filter { $0 != presenter }
            delays.remove(presenter: presenter)
        }
    }
 
    fileprivate func hideCurrent(animated: Bool = true) {
        guard let current = _current, !current.isHiding else { return }
        let action = { [weak self] in
            current.hide(animated: animated) { (completed) in
                guard completed, let self else { return }
                guard self._current === current else { return }
                self.counts[current.id] = nil
                self._current = nil
            }
        }
        let delay = current.delayHide ?? 0
        Task {
            try? await Task.sleep(seconds: delay)
            action()
        }
    }

    fileprivate weak var autohideToken: Presenter?

    fileprivate func queueAutoHide() {
        guard let current = _current else { return }
        autohideToken = current
        if let pauseDuration = current.pauseDuration {
            Task { [weak self] in
                try? await Task.sleep(seconds: pauseDuration)
                // Make sure we've still got a green light to auto-hide.
                guard let self, self.autohideToken == current else { return }
                self.internalHide(presenter: current)
            }
        }
    }

    deinit {
        guard let current = _current else { return }
        Task { @MainActor [current] in
            current.hide(animated: true) { _ in }
        }
    }
}

/*
 MARK: - Accessing messages
 */

extension SwiftMessages {

    /**
     Returns the message view of type `T` if it is currently being shown or hidden.

     - Returns: The view of type `T` if it is currently being shown or hidden.
     */
    public func current<T: UIView>() -> T? {
        _current?.view as? T
    }

    /**
     Returns a message view with the given `id` if it is currently being shown or hidden.

     - Parameter id: The id of a message that adopts `Identifiable`.
     - Returns: The view with matching id if currently being shown or hidden.
    */
    public func current<T: UIView>(id: String) -> T? {
        _current?.id == id ? _current?.view as? T : nil
    }

    /**
     Returns a message view with the given `id` if it is currently in the queue to be shown.

     - Parameter id: The id of a message that adopts `Identifiable`.
     - Returns: The view with matching id if currently queued to be shown.
     */
    public func queued<T: UIView>(id: String) -> T? {
        queue.first { $0.id == id }?.view as? T
    }

    /**
     Returns a message view with the given `id` if it is currently being 
     shown, hidden or in the queue to be shown.

     - Parameter id: The id of a message that adopts `Identifiable`.
     - Returns: The view with matching id if currently queued to be shown.
     */
    public func currentOrQueued<T: UIView>(id: String) -> T? {
        return current(id: id) ?? queued(id: id)
    }
}

/*
 MARK: - PresenterDelegate
 */

extension SwiftMessages: PresenterDelegate {

    func hide(presenter: Presenter) {
        self.internalHide(presenter: presenter)
    }

    public func hide(animator: Animator) {
        guard let presenter = self.presenter(forAnimator: animator) else { return }
        self.internalHide(presenter: presenter)
    }

    public func panStarted(animator: Animator) {
        autohideToken = nil
    }

    public func panEnded(animator: Animator) {
        queueAutoHide()
    }

    private func presenter(forAnimator animator: Animator) -> Presenter? {
        if let current = _current, animator === current.animator {
            return current
        }
        let queued = queue.filter { $0.animator === animator }
        return queued.first
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
        #if swift(>=4.1)
        guard let view = arrayOfViews.compactMap( { $0 as? T} ).first else { throw SwiftMessagesError.cannotLoadViewFromNib(nibName: name) }
        #else
        guard let view = arrayOfViews.flatMap( { $0 as? T} ).first else { throw SwiftMessagesError.cannotLoadViewFromNib(nibName: name) }
        #endif
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
    nonisolated public static var sharedInstance: SwiftMessages {
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

    public static func hide(animated: Bool = true) {
        globalInstance.hide(animated: animated)
    }
    
    public static func hideAll() {
        globalInstance.hideAll()
    }
    
    public static func hide(id: String) {
        globalInstance.hide(id: id)
    }

    public static func hideCounted(id: String) {
        globalInstance.hideCounted(id: id)
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

    public static func current<T: UIView>(id: String) -> T? {
        return globalInstance.current(id: id)
    }

    public static func queued<T: UIView>(id: String) -> T? {
        return globalInstance.queued(id: id)
    }

    public static func currentOrQueued<T: UIView>(id: String) -> T? {
        return globalInstance.currentOrQueued(id: id)
    }

    public static func count(id: String) -> Int {
        return globalInstance.count(id: id)
    }

    public static func set(count: Int, for id: String) {
        globalInstance.set(count: count, for: id)
    }
}
