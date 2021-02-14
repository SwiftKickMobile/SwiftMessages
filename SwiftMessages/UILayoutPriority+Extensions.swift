//
//  UILayoutPriority+Extensions.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 2/14/21.
//  Copyright © 2021 SwiftKick Mobile. All rights reserved.
//

import UIKit

/// The priority used for `MessageSizeable` constraints
public extension UILayoutPriority {
    static let aboveMessageSizeable: UILayoutPriority = messageInset + 1
    static let belowMessageSizeable: UILayoutPriority = messageSize - 1
    static let messageSize: UILayoutPriority = UILayoutPriority(900)
    static let messageInset: UILayoutPriority = UILayoutPriority(901)
}

