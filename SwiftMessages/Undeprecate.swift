//
//  Undeprecate.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/28/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import Foundation

/// A workaround for suppressing internal warnings about deprecated APIs
/// being usedf or backward compatibility.
protocol Undeprecated {
    var statusBarOffset: CGFloat { get set }
    var safeAreaTopOffset: CGFloat { get set }
    var safeAreaBottomOffset: CGFloat { get set }
}

extension MarginAdjustable {
    var undeprecated: Undeprecated { return self as! Undeprecated }
}

