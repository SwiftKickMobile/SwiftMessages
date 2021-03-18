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
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .filter { $0.isKeyWindow }
                .first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    #endif
}
