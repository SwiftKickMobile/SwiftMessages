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
    case Info
    case Success
    case Warning
    case Error
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
        return UIImage(named: rawValue, inBundle: NSBundle.sm_frameworkBundle(), compatibleWithTraitCollection: nil)!
    }
}

/// The IconStyle enum specifies the different variations of the included icons.
public enum IconStyle {
    
    case Default
    case Light
    case Subtle
    
    /// Returns the image for the given theme
    public func image(theme theme: Theme) -> UIImage {
        switch (theme, self) {
        case (.Info, .Default): return Icon.Info.image
        case (.Info, .Light): return Icon.InfoLight.image
        case (.Info, .Subtle): return Icon.InfoSubtle.image
        case (.Success, .Default): return Icon.Success.image
        case (.Success, .Light): return Icon.SuccessLight.image
        case (.Success, .Subtle): return Icon.SuccessSubtle.image
        case (.Warning, .Default): return Icon.Warning.image
        case (.Warning, .Light): return Icon.WarningLight.image
        case (.Warning, .Subtle): return Icon.WarningSubtle.image
        case (.Error, .Default): return Icon.Error.image
        case (.Error, .Light): return Icon.ErrorLight.image
        case (.Error, .Subtle): return Icon.ErrorSubtle.image
        }
    }
}
