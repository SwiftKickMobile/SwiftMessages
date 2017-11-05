//
//  Theme.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/7/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

/// The theme enum specifies the built-in theme options
public enum Theme {
    case info
    case success
    case warning
    case error
}

/// The Icon enum provides type-safe access to the included icons.
public enum Icon: String {
    
    case error = "errorIcon"
    case warning = "warningIcon"
    case success = "successIcon"
    case info = "infoIcon"
    case errorLight = "errorIconLight"
    case warningLight = "warningIconLight"
    case successLight = "successIconLight"
    case infoLight = "infoIconLight"
    case errorSubtle = "errorIconSubtle"
    case warningSubtle = "warningIconSubtle"
    case successSubtle = "successIconSubtle"
    case infoSubtle = "infoIconSubtle"
    
    /// Returns the associated image.
    public var image: UIImage {
        return UIImage(named: rawValue, in: Bundle.sm_frameworkBundle(), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
    }
}

/// The IconStyle enum specifies the different variations of the included icons.
public enum IconStyle {
    
    case `default`
    case light
    case subtle
    case none
    
    /// Returns the image for the given theme
    public func image(theme: Theme) -> UIImage? {
        switch (theme, self) {
        case (.info, .default): return Icon.info.image
        case (.info, .light): return Icon.infoLight.image
        case (.info, .subtle): return Icon.infoSubtle.image
        case (.success, .default): return Icon.success.image
        case (.success, .light): return Icon.successLight.image
        case (.success, .subtle): return Icon.successSubtle.image
        case (.warning, .default): return Icon.warning.image
        case (.warning, .light): return Icon.warningLight.image
        case (.warning, .subtle): return Icon.warningSubtle.image
        case (.error, .default): return Icon.error.image
        case (.error, .light): return Icon.errorLight.image
        case (.error, .subtle): return Icon.errorSubtle.image
        default: return nil
        }
    }
}
