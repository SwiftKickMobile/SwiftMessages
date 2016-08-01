//
//  Configuration.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

public enum PresentationContext {
    case InKeyWindow
    case InWindow(_: UIWindow)
    case OverWindow(windowLevel: UIWindowLevel)
    case InViewController(_: UIViewController)
    case InTopViewController(_: UIWindow)
}

public enum PresentationStyle {
    case Top
    case Bottom
}

//public enum AnimationStyle {
//    
//    public static var defaultAnimationStyle = AnimationStyle.Default(showDuration: 0.5, hideDuration: 0.5)
//    public static var springAnimationStyle = AnimationStyle.Spring(showDuration: 0.5, hideDuration: 0.5)
//    
//    case Default(showDuration: NSTimeInterval, hideDuration: NSTimeInterval)
//    case Spring(showDuration: NSTimeInterval, hideDuration: NSTimeInterval)
//    
//    public typealias Animator = (animationBlockCallback: () -> Void) -> Void
//    case Custom(showAnimator: Animator, hideAnimator: Animator)
//}

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
    case CannotFindContainer
}

public struct Configuration<V: UIView> {
    
    public typealias ViewConfiguration = (view: V) -> Void
    
    public var viewConfigurations: [ViewConfiguration] = []

    public init() {
        self.viewConfigurations = []
    }

    public init(viewConfiguration: ViewConfiguration) {
        self.viewConfigurations = [viewConfiguration]
    }

    public init(viewConfigurations: [ViewConfiguration]) {
        self.viewConfigurations = viewConfigurations
    }

    public func show() throws {
       try Presenter(configuration: self).show()
    }

    public var nibName: String?
    
    public var presentationStyle = PresentationStyle.Top
    
//    public var animationStyle = AnimationStyle.defaultAnimationStyle
    
    public var presentationContext = PresentationContext.InKeyWindow
}
