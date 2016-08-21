//
//  PassthroughView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/5/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

class PassthroughView: UIView {
    
    var tapRecognizer: UITapGestureRecognizer?
    
    var tappedHander: (() -> Void)? {
        didSet {
            if let tap = tapRecognizer {
                removeGestureRecognizer(tap)
            }
            if tappedHander == nil { return }
            let tap = UITapGestureRecognizer(target: self, action: #selector(PassthroughView.tapped))
            addGestureRecognizer(tap)
        }
    }
    
    @objc func tapped() {
        tappedHander?()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self && tappedHander == nil ? nil : view
    }
}
