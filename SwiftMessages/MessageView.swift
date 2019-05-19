//
//  MessageView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

/*
 */
open class MessageView: BaseView, Identifiable, AccessibleMessage {
    
    /*
     MARK: - Button tap handler
     */
    
    /// An optional button tap handler. The `button` is automatically
    /// configured to call this tap handler on `.TouchUpInside`.
    open var buttonTapHandler: ((_ button: UIButton) -> Void)?
    
    @objc func buttonTapped(_ button: UIButton) {
        buttonTapHandler?(button)
    }

    /*
     MARK: - Touch handling
     */

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Only accept touches within the background view. Anything outside of the
        // background view's bounds should be transparent and does not need to receive
        // touches. This helps with tap dismissal when using `DimMode.gray` and `DimMode.color`.
        return backgroundView == self
            ? super.point(inside: point, with: event)
            : backgroundView.point(inside: convert(point, to: backgroundView), with: event)
    }

    /*
     MARK: - IB outlets
     */
    
    /// An optional title label.
    @IBOutlet open var titleLabel: UILabel?
    
    /// An optional body text label.
    @IBOutlet open var bodyLabel: UILabel?
    
    /// An optional icon image view.
    @IBOutlet open var iconImageView: UIImageView?
    
    /// An optional icon label (e.g. for emoji character, icon font, etc.).
    @IBOutlet open var iconLabel: UILabel?
    
    /// An optional button. This buttons' `.TouchUpInside` event will automatically
    /// invoke the optional `buttonTapHandler`, but its fine to add other target
    /// action handlers can be added.
    @IBOutlet open var button: UIButton? {
        didSet {
            if let old = oldValue {
                old.removeTarget(self, action: #selector(MessageView.buttonTapped(_:)), for: .touchUpInside)
            }
            if let button = button {
                button.addTarget(self, action: #selector(MessageView.buttonTapped(_:)), for: .touchUpInside)
            }
        }
    }
    
    /*
     MARK: - Identifiable
     */
    
    open var id: String {
        get {
            return customId ?? "MessageView:title=\(String(describing: titleLabel?.text)), body=\(String(describing: bodyLabel?.text))"
        }
        set {
            customId = newValue
        }
    }
    
    private var customId: String?

    /*
     MARK: - AccessibleMessage
     */

    /**
     An optional prefix for the `accessibilityMessage` that can
     be used to futher clarify the message for VoiceOver. For example, 
     the view's background color or icon might convey that a message is
     a warning, in which case one may specify the value "warning".
     */
    open var accessibilityPrefix: String?

    open var accessibilityMessage: String? {
        #if swift(>=4.1)
        let components = [accessibilityPrefix, titleLabel?.text, bodyLabel?.text].compactMap { $0 }
        #else
        let components = [accessibilityPrefix, titleLabel?.text, bodyLabel?.text].flatMap { $0 }
        #endif
        guard components.count > 0 else { return nil }
        return components.joined(separator: ", ")
    }

    public var accessibilityElement: NSObject? {
        return backgroundView
    }

    open var additonalAccessibilityElements: [NSObject]? {
        var elements: [NSObject] = []
        func getAccessibleSubviews(view: UIView) {
            for subview in view.subviews {
                if subview.isAccessibilityElement {
                    elements.append(subview)
                } else {
                    // Only doing this for non-accessible `subviews`, which avoids
                    // including button labels, etc.
                    getAccessibleSubviews(view: subview)
                }
            }
        }
        getAccessibleSubviews(view: self.backgroundView)
        return elements
    }
}

/*
 MARK: - Creating message views
 
 This extension provides several convenience functions for instantiating
 `MessageView` from the included nib files in a type-safe way. These nib 
 files can be found in the Resources folder and can be drag-and-dropped 
 into a project and modified. You may still use these APIs if you've
 copied the nib files because SwiftMessages looks for them in the main
 bundle first. See `SwiftMessages` for additional nib loading options.
 */

extension MessageView {
    
    /**
     Specifies one of the nib files included in the Resources folders.
     */
    public enum Layout: String {
        
        /**
         The standard message view that stretches across the full width of the
         container view.
         */
        case messageView = "MessageView"
        
        /**
         A floating card-style view with rounded corners.
         */
        case cardView = "CardView"

        /**
         Like `CardView` with one end attached to the super view.
         */
        case tabView = "TabView"

        /**
         A 20pt tall view that can be used to overlay the status bar.
         Note that this layout will automatically grow taller if displayed
         directly under the status bar (see the `ContentInsetting` protocol).
         */
        case statusLine = "StatusLine"

        /**
         A floating card-style view with elements centered and arranged vertically.
         This view is typically used with `.center` presentation style.         
         */
        case centeredView = "CenteredView"
    }
    
    /**
     Loads the nib file associated with the given `Layout` and returns the first
     view found in the nib file with the matching type `T: MessageView`.
     
     - Parameter layout: The `Layout` option to use.
     - Parameter filesOwner: An optional files owner.
     
     - Returns: An instance of generic view type `T: MessageView`.
     */
    public static func viewFromNib<T: MessageView>(layout: Layout, filesOwner: AnyObject = NSNull.init()) -> T {
        return try! SwiftMessages.viewFromNib(named: layout.rawValue)
    }
    
    /**
     Loads the nib file associated with the given `Layout` from
     the given bundle and returns the first view found in the nib
     file with the matching type `T: MessageView`.
     
     - Parameter layout: The `Layout` option to use.
     - Parameter bundle: The name of the bundle containing the nib file.
     - Parameter filesOwner: An optional files owner.
     
     - Returns: An instance of generic view type `T: MessageView`.
     */
    public static func viewFromNib<T: MessageView>(layout: Layout, bundle: Bundle, filesOwner: AnyObject = NSNull.init()) -> T {
        return try! SwiftMessages.viewFromNib(named: layout.rawValue, bundle: bundle, filesOwner: filesOwner)
    }
}

/*
 MARK: - Layout adjustments

 This extention provides a few convenience functions for adjusting the layout.
 */

extension MessageView {
    /**
     Constrains the image view to a specified size. By default, the size of the
     image view is determined by its `intrinsicContentSize`.
     
     - Parameter size: The size to be translated into Auto Layout constraints.
     - Parameter contentMode: The optional content mode to apply.
     */
    public func configureIcon(withSize size: CGSize, contentMode: UIView.ContentMode? = nil) {
        var views: [UIView] = []
        if let iconImageView = iconImageView { views.append(iconImageView) }
        if let iconLabel = iconLabel { views.append(iconLabel) }
        views.forEach {
            let constraints = [$0.heightAnchor.constraint(equalToConstant: size.height),
                               $0.widthAnchor.constraint(equalToConstant: size.width)]
            constraints.forEach { $0.priority = UILayoutPriority(999.0) }
            $0.addConstraints(constraints)
            if let contentMode = contentMode {
                $0.contentMode = contentMode
            }
        }
    }
}

/*
 MARK: - Theming
 
 This extention provides a few convenience functions for setting styles,
 colors and icons. You are encouraged to write your own such functions
 if these don't exactly meet your needs.
 */

extension MessageView {
    
    /**
     A convenience function for setting some pre-defined colors and icons.
     
     - Parameter theme: The theme type to use.
     - Parameter iconStyle: The icon style to use. Defaults to `.Default`.
     */
    public func configureTheme(_ theme: Theme, iconStyle: IconStyle = .default) {
        let iconImage = iconStyle.image(theme: theme)
        switch theme {
        case .info:
            let backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            let foregroundColor = UIColor.darkText
            configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: iconImage)
        case .success:
            let backgroundColor = UIColor(red: 97.0/255.0, green: 161.0/255.0, blue: 23.0/255.0, alpha: 1.0)
            let foregroundColor = UIColor.white
            configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: iconImage)
        case .warning:
            let backgroundColor = UIColor(red: 238.0/255.0, green: 189.0/255.0, blue: 34.0/255.0, alpha: 1.0)
            let foregroundColor = UIColor.white
            configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: iconImage)
        case .error:
            let backgroundColor = UIColor(red: 249.0/255.0, green: 66.0/255.0, blue: 47.0/255.0, alpha: 1.0)
            let foregroundColor = UIColor.white
            configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: iconImage)
        }
    }
    
    /**
     A convenience function for setting a foreground and background color.
     Note that images will only display the foreground color if they're
     configured with UIImageRenderingMode.AlwaysTemplate.
     
     - Parameter backgroundColor: The background color to use.
     - Parameter foregroundColor: The foreground color to use.
     */
    public func configureTheme(backgroundColor: UIColor, foregroundColor: UIColor, iconImage: UIImage? = nil, iconText: String? = nil) {
        iconImageView?.image = iconImage
        iconLabel?.text = iconText
        iconImageView?.tintColor = foregroundColor
        let backgroundView = self.backgroundView ?? self
        backgroundView.backgroundColor = backgroundColor
        iconLabel?.textColor = foregroundColor
        titleLabel?.textColor = foregroundColor
        bodyLabel?.textColor = foregroundColor
        button?.backgroundColor = foregroundColor
        button?.tintColor = backgroundColor
        button?.contentEdgeInsets = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
        button?.layer.cornerRadius = 5.0
        iconImageView?.isHidden = iconImageView?.image == nil
        iconLabel?.isHidden = iconLabel?.text == nil
    }
}

/*
 MARK: - Configuring the content
 
 This extension provides a few convenience functions for configuring the
 message content. You are encouraged to write your own such functions
 if these don't exactly meet your needs.
 
 SwiftMessages does not try to be clever by adjusting the layout based on 
 what content you configure. All message elements are optional and it is
 up to you to hide or remove elements you don't need. The easiest way to
 remove unwanted elements is to drag-and-drop one of the included nib
 files into your project as a starting point and make changes.
 */

extension MessageView {
    
    /**
     Sets the message body text.
     
     - Parameter body: The message body text to use.
     */
    public func configureContent(body: String) {
        bodyLabel?.text = body
    }
    
    /**
     Sets the message title and body text.
     
     - Parameter title: The message title to use.
     - Parameter body: The message body text to use.
     */
    public func configureContent(title: String, body: String) {
        configureContent(body: body)
        titleLabel?.text = title
    }
    
    /**
     Sets the message title, body text and icon image. Also hides the
     `iconLabel`.
     
     - Parameter title: The message title to use.
     - Parameter body: The message body text to use.
     - Parameter iconImage: The icon image to use.
     */
    public func configureContent(title: String, body: String, iconImage: UIImage) {
        configureContent(title: title, body: body)
        iconImageView?.image = iconImage
        iconImageView?.isHidden = false
        iconLabel?.text = nil
        iconLabel?.isHidden = true
    }
    
    /**
     Sets the message title, body text and icon text (e.g. an emoji).
     Also hides the `iconImageView`.
     
     - Parameter title: The message title to use.
     - Parameter body: The message body text to use.
     - Parameter iconText: The icon text to use (e.g. an emoji).
     */
    public func configureContent(title: String, body: String, iconText: String) {
        configureContent(title: title, body: body)
        iconLabel?.text = iconText
        iconLabel?.isHidden = false
        iconImageView?.isHidden = true
        iconImageView?.image = nil
    }
    
    /**
     Sets all configurable elements.
     
     - Parameter title: The message title to use.
     - Parameter body: The message body text to use.
     - Parameter iconImage: The icon image to use.
     - Parameter iconText: The icon text to use (e.g. an emoji).
     - Parameter buttonImage: The button image to use.
     - Parameter buttonTitle: The button title to use.
     - Parameter buttonTapHandler: The button tap handler block to use.
     */
    public func configureContent(title: String?, body: String?, iconImage: UIImage?, iconText: String?, buttonImage: UIImage?, buttonTitle: String?, buttonTapHandler: ((_ button: UIButton) -> Void)?) {
        titleLabel?.text = title
        bodyLabel?.text = body
        iconImageView?.image = iconImage
        iconLabel?.text = iconText
        button?.setImage(buttonImage, for: .normal)
        button?.setTitle(buttonTitle, for: .normal)
        self.buttonTapHandler = buttonTapHandler
        iconImageView?.isHidden = iconImageView?.image == nil
        iconLabel?.isHidden = iconLabel?.text == nil
    }
}


