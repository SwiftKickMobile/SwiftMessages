//
//  PassthroughView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/5/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

class PassthroughView: UIControl {

    var tappedHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCommon()
    }

    private func initCommon() {
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    @objc func tapped() {
        tappedHandler?()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self && tappedHandler == nil ? nil : view
    }
}
