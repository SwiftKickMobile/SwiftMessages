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
 of the optional SwiftMessages protocols and provides some convenience methods
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
    
    /**
     The view containing the message view content and the target of the
     `installContentView` convenience method. Defaults to `self`.
     
     This view has no specific functionality in SwiftMessages, but is provided
     as a reference to the content as a convenience. It is a distinctly separate
     property from `backgroundView`, though they may point to the same view (and
     they both point to `self` by default) to accommodate `UIStackViews` as
     content views, which do not render a background
     (see MessageView.nib and CardView.nib).
    */
    @IBOutlet public var contentView: UIView!

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
     A convenience method for installing a content view as a subview of `backgroundView`
     and pinning the edges to `backgroundView` with the specified `insets`.
     
     - Parameter contentView: The view to be installed into the background view
       and assigned to the `contentView` property.
     - Parameter insets: The amount to inset the content view from the background view.
       Default is zero inset.
     */
    public func installContentView(contentView: UIView, insets: UIEdgeInsets = UIEdgeInsetsZero) {
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = UIEdgeInsetsInsetRect(self.bounds, insets)
        backgroundView.addSubview(contentView)
        self.contentView = contentView
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
    
    /// A convenience method to configure a default drop shadow effect.
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
