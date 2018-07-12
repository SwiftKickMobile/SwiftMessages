
//
//  BaseView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/17/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

/*
 The `BaseView` class is a reusable message view base class that implements some
 of the optional SwiftMessages protocols and provides some convenience functions
 and a configurable tap handler. Message views do not need to inherit from `BaseVew`.
 */
open class BaseView: UIView, BackgroundViewable, MarginAdjustable {

    /*
     MARK: - IB outlets
     */

    /**
     Fulfills the `BackgroundViewable` protocol and is the target for
     the optional `tapHandler` block. Defaults to `self`.
     */
    @IBOutlet open weak var backgroundView: UIView! {
        didSet {
            if let old = oldValue {
                old.removeGestureRecognizer(tapRecognizer)
            }
            installTapRecognizer()
        }
    }

    // The `contentView` property was removed because it no longer had any functionality
    // in the framework. This is a minor backwards incompatible change. If you've copied
    // one of the included nib files from a previous release, you may get a key-value
    // coding runtime error related to contentView, in which case you can subclass the
    // view and add a `contentView` property or you can remove the outlet connection in
    // Interface Builder.
    // @IBOutlet public var contentView: UIView!

    /*
     MARK: - Initialization
     */

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundView = self
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundView = self
    }

    open override func awakeFromNib() {
        layoutMargins = UIEdgeInsets.zero
    }

    /*
     MARK: - Installing background and content
     */

    /**
     A convenience function for installing a background view and pinning to the layout margins.
     This is useful for creating programatic layouts where the background view needs to be
     inset from the message view's bounds.

     - Parameter backgroundView: The view to be installed as a subview and
     assigned to the `backgroundView` property.
     */
    open func installBackgroundView(_ backgroundView: UIView) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        if backgroundView != self {
            backgroundView.removeFromSuperview()
        }
        addSubview(backgroundView)
        self.backgroundView = backgroundView
        let top = NSLayoutConstraint(item: backgroundView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .topMargin, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: backgroundView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .leftMargin, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: backgroundView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottomMargin, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: backgroundView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .rightMargin, multiplier: 1.0, constant: 0)
        addConstraints([top, left, bottom, right])
        installTapRecognizer()
    }

    /**
     A convenience function for installing a content view as a subview of `backgroundView`
     and pinning the edges to `backgroundView` with the specified `insets`.

     - Parameter contentView: The view to be installed into the background view
     and assigned to the `contentView` property.
     - Parameter insets: The amount to inset the content view from the background view.
     Default is zero inset.
     */
    open func installContentView(_ contentView: UIView, insets: UIEdgeInsets = UIEdgeInsets.zero) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(contentView)
        let top = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: backgroundView, attribute: .top, multiplier: 1.0, constant: insets.top)
        let left = NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: backgroundView, attribute: .left, multiplier: 1.0, constant: insets.left)
        let bottom = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: backgroundView, attribute: .bottom, multiplier: 1.0, constant: -insets.bottom)
        let right = NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: backgroundView, attribute: .right, multiplier: 1.0, constant: -insets.right)
        backgroundView.addConstraints([top, left, bottom, right])
    }

    /*
     MARK: - Tap handler
     */

    /**
     An optional tap handler that will be called when the `backgroundView` is tapped.
     */
    open var tapHandler: ((_ view: BaseView) -> Void)? {
        didSet {
            installTapRecognizer()
        }
    }

    fileprivate lazy var tapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageView.tapped))
        return tapRecognizer
    }()

    @objc func tapped() {
        tapHandler?(self)
    }

    fileprivate func installTapRecognizer() {
        guard let backgroundView = backgroundView else { return }
        removeGestureRecognizer(tapRecognizer)
        backgroundView.removeGestureRecognizer(tapRecognizer)
        if tapHandler != nil {
            // Only install the tap recognizer if there is a tap handler,
            // which makes it slightly nicer if one wants to install
            // a custom gesture recognizer.
            backgroundView.addGestureRecognizer(tapRecognizer)
        }
    }

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if backgroundView != self {
            let backgroundViewPoint = convert(point, to: backgroundView)
            return backgroundView.point(inside: backgroundViewPoint, with: event)
        }
        return super.point(inside: point, with: event)
    }

    /*
     MARK: - MarginAdjustable

     These properties fulfill the `MarginAdjustable` protocol and are exposed
     as `@IBInspectables` so that they can be adjusted directly in nib files
     (see MessageView.nib).
     */

    @IBInspectable open var bounceAnimationOffset: CGFloat = 5.0
     
    /**
     For iOS 10 and lower, an optional absolute value for the top margin for cases
     where the view appears behind the status bar.
     */
    @IBInspectable open var statusBarOffset: CGFloat = 20.0
    
    /**
     For iOS 11 and greater, an optional top margin adjustment for cases where the
     view appears behind known safe zone elements, such as the status bar and the
     iPhone X notch, as determined by the `safeZoneConflicts` property. This
     value is added to adjustments already made by SwiftMessages in case the
     defaults don't work for a particular layout.
     */
    @IBInspectable open var safeAreaTopOffset: CGFloat = 0.0

    /**
     For iOS 11 and greater, an optional bottom margin adjustment for cases where the view
     appears behind known safe zone elements, such as the home indicator, as determined
     by the `safeZoneConflicts` property. This value is added to adjustments already made
     by SwiftMessages in case the defaults don't work for a particular layout.
     */
    @IBInspectable open var safeAreaBottomOffset: CGFloat = 0.0

    /*
     MARK: - Setting preferred height
     */

    /**
     An optional value that sets the message view's intrinsic content height.
     This can be used as a way to specify a fixed height for the message view.
     Note that this height is not guaranteed depending on anyt Auto Layout
     constraints used within the message view.
     */
    open var preferredHeight: CGFloat? {
        didSet {
            setNeedsLayout()
        }
    }

    open override var intrinsicContentSize: CGSize {
        if let preferredHeight = preferredHeight {
            return CGSize(width: UIViewNoIntrinsicMetric, height: preferredHeight)
        }
        return super.intrinsicContentSize
    }
}

/*
 MARK: - Theming
 */

extension BaseView {

    /// A convenience function to configure a default drop shadow effect.
    open func configureDropShadow() {
        let layer = backgroundView.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 0.4
        layer.masksToBounds = false
        updateShadowPath()
    }

    private func updateShadowPath() {
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }
}
    
