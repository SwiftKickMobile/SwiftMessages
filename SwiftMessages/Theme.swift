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
    
    case Error = "errorIcon"
    case Warning = "warningIcon"
    case Success = "successIcon"
    case Info = "infoIcon"
    case ErrorLight = "errorIconLight"
    case WarningLight = "warningIconLight"
    case SuccessLight = "successIconLight"
    case InfoLight = "infoIconLight"
    case ErrorSubtle = "errorIconSubtle"
    case WarningSubtle = "warningIconSubtle"
    case SuccessSubtle = "successIconSubtle"
    case InfoSubtle = "infoIconSubtle"
    
    /// Returns the associated image.
    public var image: UIImage {        
        return UIImage(named: rawValue, in: Bundle.sm_frameworkBundle(), compatibleWith: nil)!
    }
}

/// The IconStyle enum specifies the different variations of the included icons.
public enum IconStyle {
    
    case `default`
    case light
    case subtle
    
    /// Returns the image for the given theme
    public func image(theme: Theme) -> UIImage {
        switch (theme, self) {
        case (.info, .default): return Icon.Info.image
        case (.info, .light): return Icon.InfoLight.image
        case (.info, .subtle): return Icon.InfoSubtle.image
        case (.success, .default): return Icon.Success.image
        case (.success, .light): return Icon.SuccessLight.image
        case (.success, .subtle): return Icon.SuccessSubtle.image
        case (.warning, .default): return Icon.Warning.image
        case (.warning, .light): return Icon.WarningLight.image
        case (.warning, .subtle): return Icon.WarningSubtle.image
        case (.error, .default): return Icon.Error.image
        case (.error, .light): return Icon.ErrorLight.image
        case (.error, .subtle): return Icon.ErrorSubtle.image
        }
    }
}
