//
//  BaseView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/17/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

public class BaseView: UIView, BackgroundViewable, MarginAdjustable {
    
    /*
     MARK: - IB outlets
     */
    
    @IBOutlet public var backgroundView: UIView! {
        didSet {
            if let old = oldValue {
                old.removeGestureRecognizer(tapRecognizer)
            }
            installTapRecognizer()
        }
    }
    
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
     */
    
    @IBInspectable public var bounceAnimationOffset: CGFloat = 5.0
    
    @IBInspectable public var statusBarOffset: CGFloat = 20.0
    
    
    /*
     MARK: - Setting preferred height
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
