//
//  SwiftMessagesHideKey.swift
//  SwiftMessages
//
//  Created by Mofe Ejegi on 11/05/2025.
//  Copyright © 2025 SwiftKick Mobile. All rights reserved.
//

import SwiftUI

private struct SwiftMessagesHideKey: EnvironmentKey {
    /// By default, hide the current message.
    static let defaultValue: @MainActor (Bool) -> Void = { animated in
        SwiftMessages.hide(animated: animated)
    }
}

public extension EnvironmentValues {
    /// Call this to hide the currently displayed SwiftMessages banner.
    var swiftMessagesHide: @MainActor (_ animated: Bool) -> Void {
        get { self[SwiftMessagesHideKey.self] }
        set { self[SwiftMessagesHideKey.self] = newValue }
    }
}
