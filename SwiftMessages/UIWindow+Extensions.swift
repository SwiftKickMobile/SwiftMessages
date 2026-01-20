//
//  UIWindow+Extensions.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 3/11/21.
//  Copyright © 2021 SwiftKick Mobile. All rights reserved.
//

import UIKit

extension UIWindow {
    #if !SWIFTMESSAGES_APP_EXTENSIONS
    static var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .sorted { $0.activationState.sortPriority < $1.activationState.sortPriority }
            .compactMap { $0 as? UIWindowScene }
            .compactMap { $0.windows.first { $0.isKeyWindow } }
            .first
    }
    #endif
}

@available(iOS 13.0, *)
private extension UIScene.ActivationState {
    var sortPriority: Int {
        switch self {
        case .foregroundActive: return 1
        case .foregroundInactive: return 2
        case .background: return 3
        case .unattached: return 4
        @unknown default: return 5
        }
    }
}
