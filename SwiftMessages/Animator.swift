//
//  Animator.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/4/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

public typealias AnimationCompletion = (_ completed: Bool) -> Void

public protocol AnimationDelegate: class {
    func hide(animator: Animator)
    func panStarted(animator: Animator)
    func panEnded(animator: Animator)
}

/**
 An option set that represents the known types of safe zone conflicts
 that may need custom margin adustments.
 */
public struct SafeZoneConflicts: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Message view behind status bar
    public static let statusBar = SafeZoneConflicts(rawValue: 1 << 0)

    /// Message view behind the sensor notch on iPhone X
    public static let sensorNotch = SafeZoneConflicts(rawValue: 1 << 1)

    /// Message view behind home indicator on iPhone X
    public static let homeIndicator = SafeZoneConflicts(rawValue: 1 << 2)

    /// Message view covering status bar on iPhone 8 or lower. One would expect the
    /// top safe zone to be 0, but in the current version of iOS 11, it is non-zero (20),
    /// which SwiftMessages will automatically compensate for by subtracting that amount
    /// form the layout margins.
    public static let coveredStatusBar = SafeZoneConflicts(rawValue: 1 << 3)
}

public class AnimationContext {

    public let messageView: UIView
    public let containerView: UIView
    public let safeZoneConflicts: SafeZoneConflicts
    public let interactiveHide: Bool

    init(messageView: UIView, containerView: UIView, safeZoneConflicts: SafeZoneConflicts, interactiveHide: Bool) {
        self.messageView = messageView
        self.containerView = containerView
        self.safeZoneConflicts = safeZoneConflicts
        self.interactiveHide = interactiveHide
    }
}

public protocol Animator: class {

    weak var delegate: AnimationDelegate? { get set }

    func show(context: AnimationContext, completion: @escaping AnimationCompletion)

    func hide(context: AnimationContext, completion: @escaping AnimationCompletion)
}
