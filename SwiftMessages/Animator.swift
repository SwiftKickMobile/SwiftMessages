//
//  Animator.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/4/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import Foundation

public typealias AnimationCompletion = (_ completed: Bool) -> Void

public protocol AnimationDelegate: class {
    func hide(animator: Animator)
    func panStarted(animator: Animator)
    func panEnded(animator: Animator)
}

public class AnimationContext {

    public let messageView: UIView
    public let containerView: UIView
    public let behindStatusBar: Bool
    public let interactiveHide: Bool

    init(messageView: UIView, containerView: UIView, behindStatusBar: Bool, interactiveHide: Bool) {
        self.messageView = messageView
        self.containerView = containerView
        self.behindStatusBar = behindStatusBar
        self.interactiveHide = interactiveHide
    }
}

public protocol Animator: class {

    weak var delegate: AnimationDelegate? { get set }

    func show(context: AnimationContext, completion: @escaping AnimationCompletion)

    func hide(context: AnimationContext, completion: @escaping AnimationCompletion)
}
