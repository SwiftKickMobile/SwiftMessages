//
//  HapticMessage.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 1/23/24.
//  Copyright © 2024 SwiftKick Mobile. All rights reserved.
//

import Foundation

/**
 Message views that conform to `HapticMessage` can specify a haptic feedback to be used when presented.
 */
protocol HapticMessage {
    var defaultHaptic: SwiftMessages.Haptic? { get }
}
