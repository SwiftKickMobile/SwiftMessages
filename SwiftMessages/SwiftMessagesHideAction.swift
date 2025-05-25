//
//  SwiftMessagesHideKey.swift
//  SwiftMessages
//
//  Created by Mofe Ejegi on 11/05/2025.
//  Copyright © 2025 SwiftKick Mobile. All rights reserved.
//

import SwiftUI

/// A SwiftUI-style action for dismissing the current SwiftMessage.
///
/// - `hide()` → animated hide
/// - `hide(animated: Bool)` → explicit control
public struct SwiftMessagesHideAction {
    public init() {}
    
    /// Dismiss with animation.
    @MainActor
    public func callAsFunction() {
        SwiftMessages.hide(animated: true)
    }
    
    /// Dismiss, optionally animated.
    @MainActor
    public func callAsFunction(animated: Bool) {
        SwiftMessages.hide(animated: animated)
    }
}

// MARK: ––– Environment Key & Value –––

private struct SwiftMessagesHideKey: EnvironmentKey {
    /// Default to our action struct, which itself defaults to animated.
    static let defaultValue: SwiftMessagesHideAction = SwiftMessagesHideAction()
}

public extension EnvironmentValues {
    /// Inject `@Environment(\.swiftMessagesHide)` into your views.
    /// - Use `hide()` for the default animated dismissal.
    /// - Use `hide(false)` to bypass animation.
    var swiftMessagesHide: SwiftMessagesHideAction {
        get { self[SwiftMessagesHideKey.self] }
        set { self[SwiftMessagesHideKey.self] = newValue }
    }
}
