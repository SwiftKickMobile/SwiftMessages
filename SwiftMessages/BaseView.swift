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
public class BaseView: UIView, BackgroundViewable, MarginAdjustable {
    
    /*
     MARK: - IB outlets
     */
    
    /**
     Fulfills the `BackgroundViewable` protocol and is the target for
     the optional `tapHandler` block. Defaults to `self`.
     */
    @IBOutlet public var backgroundView: UIView! {
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

    public override func awakeFromNib() {
        layoutMargins = UIEdgeInsetsZero
    }

    /*
     MARK: - Installing content
     */
    
    /**
     A convenience function for installing a content view as a subview of `backgroundView`
     and pinning the edges to `backgroundView` with the specified `insets`.
     
     - Parameter contentView: The view to be installed into the background view
       and assigned to the `contentView` property.
     - Parameter insets: The amount to inset the content view from the background view.
       Default is zero inset.
     */
    public func installContentView(contentView: UIView, insets: UIEdgeInsets = UIEdgeInsetsZero) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(contentView)
        let top = NSLayoutConstraint(item: contentView, attribute: .Top, relatedBy: .Equal, toItem: backgroundView, attribute: .TopMargin, multiplier: 1.0, constant: insets.top)
        let left = NSLayoutConstraint(item: contentView, attribute: .Left, relatedBy: .Equal, toItem: backgroundView, attribute: .LeftMargin, multiplier: 1.0, constant: insets.left)
        let bottom = NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: backgroundView, attribute: .BottomMargin, multiplier: 1.0, constant: -insets.bottom)
        let right = NSLayoutConstraint(item: contentView, attribute: .Right, relatedBy: .Equal, toItem: backgroundView, attribute: .RightMargin, multiplier: 1.0, constant: -insets.right)
        backgroundView.addConstraints([top, left, bottom, right])
    }
    
    /*
     MARK: - Tap handler
     */
    
    /**
     An optional tap handler that will be called when the `backgroundView` is tapped.
     */
    public var tapHandler: ((view: BaseView) -> Void)? {
        didSet {
            installTapRecognizer()
        }
    }
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageView.tapped))
        return tapRecognizer
    }()
    
    func tapped() {
        tapHandler?(view: self)
    }
    
    private func installTapRecognizer() {
        guard let backgroundView = backgroundView else { return }
        backgroundView.removeGestureRecognizer(tapRecognizer)
        if tapHandler != nil {
            // Only install the tap recognizer if there is a tap handler,
            // which makes it slightly nicer if one wants to install
            // a custom gesture recognizer.
            backgroundView.addGestureRecognizer(tapRecognizer)
        }
    }

    /*
     MARK: - MarginAdjustable
     
     These properties fulfill the `MarginAdjustable` protocol and are exposed
     as `@IBInspectables` so that they can be adjusted directly in nib files
     (see MessageView.nib).
     */
    
    @IBInspectable public var bounceAnimationOffset: CGFloat = 5.0
    
    @IBInspectable public var statusBarOffset: CGFloat = 20.0
    
    
    /*
     MARK: - Setting preferred height
     */
    
    /**
     An optional value that sets the message view's intrinsic content height.
     This can be used as a way to specify a fixed height for the message view.
     Note that this height is not guaranteed depending on anyt Auto Layout
     constraints used within the message view.
     */
    public var preferredHeight: CGFloat? {
        didSet {
            setNeedsLayout()
        }
    }
    
    public override func intrinsicContentSize() -> CGSize {
        if let preferredHeight = preferredHeight {
            return CGSizeMake(UIViewNoIntrinsicMetric, preferredHeight)
        }
        return super.intrinsicContentSize()
    }
}

/*
 MARK: - Theming
 */

extension BaseView {
    
    /// A convenience function to configure a default drop shadow effect.
    public func configureDropShadow() {
        let layer = backgroundView.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 0.4
        layer.masksToBounds = false
        updateShadowPath()
    }
    
    private func updateShadowPath() {
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).CGPath
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }
}
