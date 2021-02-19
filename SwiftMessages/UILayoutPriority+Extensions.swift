//
//  UILayoutPriority+Extensions.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 2/14/21.
//  Copyright © 2021 SwiftKick Mobile. All rights reserved.
//

import UIKit

/// The priority used for `MessageSizeable` constraints
extension UILayoutPriority {
    /// A constraint priority higher than those used for `MessageSizeable`
    public static let aboveMessageSizeable: UILayoutPriority = messageInsetsBounds + 1

    /// A constraint priority lower than those used for `MessageSizeable`
    public static let belowMessageSizeable: UILayoutPriority = messageCenter - 1

    static let messageCenter: UILayoutPriority = UILayoutPriority(900)
    static let messageSize: UILayoutPriority = UILayoutPriority(901)
    static let messageInsets: UILayoutPriority = UILayoutPriority(902)
    static let messageCenterBounds: UILayoutPriority = UILayoutPriority(903)
    static let messageSizeBounds: UILayoutPriority = UILayoutPriority(904)
    static let messageInsetsBounds: UILayoutPriority = UILayoutPriority(905)
}

