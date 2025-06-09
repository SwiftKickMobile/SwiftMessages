//
//  SwiftMessagesHideKey.swift
//  SwiftMessages
//
//  Created by Mofe Ejegi on 11/05/2025.
//  Copyright © 2025 SwiftKick Mobile. All rights reserved.
//

import SwiftUI

/// A SwiftUI-style action for dismissing the current SwiftMessage.
public struct SwiftMessagesHideAction {
    public init() {}
    
    /// Dismiss with option to disable animation.
    @MainActor
    public func callAsFunction(animated: Bool) {
        SwiftMessages.hide(animated: animated)
    }
}

public extension EnvironmentValues {
    /// Inject `@Environment(\.swiftMessagesHide)` into your views to
    /// access the SwiftUI-style action for dismissing the current SwiftMessage.
    ///
    /// Usage:
    /// ```swift
    /// @Environment(\.swiftMessagesHide) private var hide
    /// ```
    ///
    /// Then you can call it like this:
    /// ```swift
    /// hide(animated: true)
    /// ```
    var swiftMessagesHide: SwiftMessagesHideAction {
        get { self[SwiftMessagesHideKey.self] }
        set { self[SwiftMessagesHideKey.self] = newValue }
    }
}

private struct SwiftMessagesHideKey: EnvironmentKey {
    /// Default to our action struct, which itself defaults to animated.
    static let defaultValue: SwiftMessagesHideAction = SwiftMessagesHideAction()
}
