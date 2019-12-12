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
 An option set representing the known types of safe area conflicts
 that could require margin adustments on the message view in order to
 get the layouts to look right.
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

    /// Message view is over the status bar on an iPhone 8 or lower. This is a special
    /// case because we logically expect the top safe area to be zero, but it is reported as 20
    /// (which seems like an iOS bug). We use the `overStatusBar` to indicate this special case.
    public static let overStatusBar = SafeZoneConflicts(rawValue: 1 << 3)
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

    /// Adopting classes should declare as `weak`.
    var delegate: AnimationDelegate? { get set }

    func show(context: AnimationContext, completion: @escaping AnimationCompletion)

    func hide(context: AnimationContext, completion: @escaping AnimationCompletion)

    /// The show animation duration. If the animation duration is unknown, such as if using `UIDynamnicAnimator`,
    /// then profide an estimate. This value is used by `SwiftMessagesSegue`.
    var showDuration: TimeInterval { get }

    /// The hide animation duration. If the animation duration is unknown, such as if using `UIDynamnicAnimator`,
    /// then profide an estimate. This value is used by `SwiftMessagesSegue`.
    var hideDuration: TimeInterval { get }
}

