//
//  DropShadowView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/12/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

public class DropShadowView: UIView {
    
    /*
     MARK: - Configuring the theme
     */

    public func configureDropShadow() {
        configureDropShadow(self)
    }
    
    public func configureDropShadow(backgroundView: UIView) {
        self.backgroundView = backgroundView
        let layer = shadowView.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 0.4
        layer.masksToBounds = false
        updateShadowPath()
        dropShadowConfigured = true
    }

    /*
     MARK: - Installing a subview
     */
    
    public func installView(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view" : view])
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view" : view])
        addConstraints(verticalConstraints)
        addConstraints(horizontalConstraints)
    }
    
    /*
     MARK: - Constraining height
     */
    
    private var heightConstraint: NSLayoutConstraint?
    
    public func constrainHeight(height: CGFloat) {
        if heightConstraint == nil {
            let constraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[view(0)]", options: [], metrics: nil, views: ["view" : self])[0]
            heightConstraint = constraint
            self.addConstraint(constraint)
        }
        heightConstraint?.constant = height
    }
    
    /*
     MARK: - Shadow path management
     */
    
    private var dropShadowConfigured = false
    
    private func updateShadowPath() {
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).CGPath
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let layer = shadowView.layer
        if dropShadowConfigured && layer.shadowPath != nil {
            updateShadowPath()
        }
    }
    
    private weak var backgroundView: UIView?
    
    private var shadowView: UIView {
        return backgroundView ?? self
    }
}
