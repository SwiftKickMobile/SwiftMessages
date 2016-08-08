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

public struct Configuration {

    public var duration = Duration.Automatic
    
    public var presentationStyle = PresentationStyle.Top
    
    public var presentationContext = PresentationContext.Automatic

    /**
     Specifies the preferred status bar style when the view is displayed
     directly behind the status bar, such as when using `.Window`
     presentation context with a `UIWindowLevelNormal` window level
     and `.Top` presentation style.
    */
    public var preferredStatusBarStyle: UIStatusBarStyle = UIStatusBarStyle.Default
}
