//
//  CornerRoundingView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/28/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit

/// A background view that messages can use for rounding all or a subset of corners with squircles
/// (the smoother method of rounding corners that you see on app icons).
open class CornerRoundingView: UIView {

    /// Specifies the corner radius to use.
    @IBInspectable
    open var cornerRadius: CGFloat = 0 {
        didSet {
            updateMaskPath()
        }
    }

    /// Set to `true` for layouts where only the leading corners should be
    /// rounded. For example, the layout in TabView.xib rounds the bottom corners
    /// when displayed from the top and the top corners when displayed from the bottom.
    /// When this property is `true`, the `roundedCorners` property will be overwritten
    /// by relevant animators (e.g. `TopBottomAnimation`).
    @IBInspectable
    open var roundsLeadingCorners: Bool = false

    /// Specifies which corners should be rounded. When `roundsLeadingCorners = true`, relevant
    /// relevant animators (e.g. `TopBottomAnimation`) will overwrite the value of this property.
    open var roundedCorners: UIRectCorner = [.allCorners] {
        didSet {
            updateMaskPath()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        layer.mask = shapeLayer
    }

    private let shapeLayer = CAShapeLayer()

    override open func layoutSubviews() {
        super.layoutSubviews()
        updateMaskPath()
    }

    private func updateMaskPath() {
        let newPath = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii).cgPath
        // Update the `shapeLayer's` path with animation if we detect our `layer's` size is being animated.
        // This is a workaround needed for smooth rotation animations.
        if let foundAnimation = layer.findAnimation(forKeyPath: "bounds.size") {
            // Update the `shapeLayer's` path with animation, copying the relevant properties
            // from the found animation.
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = foundAnimation.duration
            animation.timingFunction = foundAnimation.timingFunction
            animation.fromValue = shapeLayer.path
            animation.toValue = newPath
            shapeLayer.add(animation, forKey: "path")
            shapeLayer.path = newPath
        } else {
            // Update the `shapeLayer's` path  without animation
            shapeLayer.path = newPath
        }
    }

    private var cornerRadii: CGSize {
        return CGSize(width: cornerRadius, height: cornerRadius)
    }
}
