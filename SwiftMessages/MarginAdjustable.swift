//
//  MarginAdjustable.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/5/16.
//  Copyright © 2016 SwiftKick Mobile LLC.LLC. All rights reserved.
//

import UIKit

public protocol MarginAdjustable {
    var bounceAnimationOffset: CGFloat { get set }
    var statusBarOffset: CGFloat { get set }
}