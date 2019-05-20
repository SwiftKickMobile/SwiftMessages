//
//  KeyboardTrackingView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 5/20/19.
//  Copyright © 2019 SwiftKick Mobile. All rights reserved.
//

import UIKit

public protocol KeyboardTrackingViewDelegate: class {
    func keyboardTrackingViewWillChange(change: KeyboardTrackingView.Change, userInfo: [AnyHashable : Any])
    func keyboardTrackingViewDidChange(change: KeyboardTrackingView.Change, userInfo: [AnyHashable : Any])
}

/// A view that adjusts it's height based on keyboard hide and show notifications.
/// Pin it to the bottom of the screen using Auto Layout and then pin views that
/// should avoid the keyboard to the top of it. Supply an instance of this class
/// on `SwiftMessages.Config.keyboardTrackingView` or `SwiftMessagesSegue.keyboardTrackingView`
/// for automatic keyboard avoidance for the entire SwiftMessages view or view controller.
open class KeyboardTrackingView: UIView {

    public enum Change {
        case show
        case hide
        case frame
    }

    public weak var delegate: KeyboardTrackingViewDelegate?

    /// Typically, when a view controller is not being displayed, keyboard
    /// tracking should be paused to avoid responding to keyboard events
    /// caused by other view controllers or apps. Setting `isPaused = true` in
    /// `viewWillAppear` and `isPaused = false` in `viewWillDisappear` usually works. This class
    /// automatically pauses and resumes when the app resigns and becomes active, respectively.
    open var isPaused = false {
        didSet {
            if !isPaused {
                isAutomaticallyPaused = false
            }
        }
    }

    /// The margin to maintain between the keyboard and the top of the view.
    @IBInspectable open var topMargin: CGFloat = 0

    override public init(frame: CGRect) {
        super.init(frame: frame)
        postInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        postInit()
    }

    private var isAutomaticallyPaused = false
    private var heightConstraint: NSLayoutConstraint!

    private func postInit() {
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pause), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resume), name: UIApplication.didBecomeActiveNotification, object: nil)
        backgroundColor = .clear
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        show(change: .frame, notification)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        show(change: .show, notification)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard !(isPaused || isAutomaticallyPaused),
            let userInfo = (notification as NSNotification).userInfo else { return }
        guard heightConstraint.constant != 0 else { return }
        delegate?.keyboardTrackingViewWillChange(change: .hide, userInfo: userInfo)
        animateKeyboardChange(change: .hide, height: 0, userInfo: userInfo)
    }

    @objc private func pause() {
        isAutomaticallyPaused = true
    }

    @objc private func resume() {
        isAutomaticallyPaused = false
    }

    private func show(change: Change, _ notification: Notification) {
        guard !(isPaused || isAutomaticallyPaused),
            let userInfo = (notification as NSNotification).userInfo,
            let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardRect = value.cgRectValue
        let thisRect = convert(bounds, to: nil)
        let newHeight = max(0, thisRect.maxY - keyboardRect.minY) + topMargin
        guard heightConstraint.constant != newHeight else { return }
        delegate?.keyboardTrackingViewWillChange(change: change, userInfo: userInfo)
        animateKeyboardChange(change: change, height: newHeight, userInfo: userInfo)
    }

    private func animateKeyboardChange(change: Change, height: CGFloat, userInfo: [AnyHashable: Any]) {
        self.heightConstraint.constant = height
        if let durationNumber = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curveNumber = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.delegate?.keyboardTrackingViewDidChange(change: change, userInfo: userInfo)
            }
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(durationNumber.doubleValue)
            UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: curveNumber.intValue)!)
            UIView.setAnimationBeginsFromCurrentState(true)
            self.superview?.layoutIfNeeded()
            UIView.commitAnimations()
            CATransaction.commit()
        }
    }
}
