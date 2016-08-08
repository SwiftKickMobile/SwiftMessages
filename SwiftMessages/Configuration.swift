//
//  Configuration.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

public enum PresentationContext {
    case Automatic
    case Window(windowLevel: UIWindowLevel)
    case ViewController(_: UIViewController)
}

public enum PresentationStyle {
    case Top
    case Bottom
}

public enum Duration {
    case Automatic
    case Forever
    case Seconds(seconds: NSTimeInterval)
}

public enum Icon {
    
    case Error
    case Warning
    case Info
    case GrinningFace
    case GrimacingFace
    case ThinkingFace
    case ImageName(name: String)
    case Text(text: String)
    
    public var image: UIImage? {
        let name: String?
        switch self {
        case .Error:
            name = "errorIcon"
        case .ImageName(let foundName):
            name = foundName
        default:
            name = nil
        }
        guard let foundName = name else { return nil }
        return UIImage(named: foundName)
    }
    
    public var text: String? {
        switch self {
        case .GrinningFace:
            return "😀"
        case .GrimacingFace:
            return "😬"
        case .ThinkingFace:
            return "🤔"
        case .Text(let text):
            return text
        default:
            return nil
        }
    }
}

enum Error: ErrorType {
    case CannotLoadViewFromNib(nibName: String)
    case NoRootViewController
}

public struct Configuration {

    public var duration = Duration.Automatic
    
    public var nibName: String?
    
    public var presentationStyle = PresentationStyle.Top
    
    public var presentationContext = PresentationContext.Automatic

    /// Works with .OverWindow presentation context
    public var preferredStatusBarStyle = UIStatusBarStyle.Default
}
