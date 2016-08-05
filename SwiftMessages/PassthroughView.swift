//
//  PassthroughView.swift
//  SwiftMessages
//
//  Created by Tim Moose on 8/5/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

class PassthroughView: UIView {
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, withEvent: event)
        return view == self ? nil : view
    }
}