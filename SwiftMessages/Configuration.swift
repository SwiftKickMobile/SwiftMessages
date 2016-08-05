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
    case NoRootViewController
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
        let view: V
        if let nibName = nibName {
            view = try V.viewFromNib(named: nibName)
        } else {
            view = try V.viewFromNib()
        }
        show(view: view)
    }
    
    public func show(view view: V) {
        let presenter = Presenter(configuration: self, view: view)
        globalManager.enqueue(presenter: presenter)
    }

    public var duration = Duration.Automatic
    
    public var nibName: String?
    
    public var presentationStyle = PresentationStyle.Top
    
    public var presentationContext = PresentationContext.Automatic

    /// Works with .OverWindow presentation context
    public var preferredStatusBarStyle = UIStatusBarStyle.Default
    
    public static func hide() {
        globalManager.hide()
    }
}
