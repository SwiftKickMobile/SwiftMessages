//
//  MaskingView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 3/11/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit


class MaskingView: PassthroughView {

    func install(keyboardTrackingView: KeyboardTrackingView) {
        self.keyboardTrackingView = keyboardTrackingView
        keyboardTrackingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(keyboardTrackingView)
        keyboardTrackingView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        keyboardTrackingView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        keyboardTrackingView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    var accessibleElements: [NSObject] = []

    weak var backgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let view = backgroundView {
                view.isUserInteractionEnabled = false
                view.frame = bounds
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                addSubview(view)
                sendSubviewToBack(view)
            }
        }
    }

    override func accessibilityElementCount() -> Int {
        return accessibleElements.count
    }

    override func accessibilityElement(at index: Int) -> Any? {
        return accessibleElements[index]
    }

    override func index(ofAccessibilityElement element: Any) -> Int {
        guard let object = element as? NSObject else { return 0 }
        return accessibleElements.firstIndex(of: object) ?? 0
    }

    init() {
        super.init(frame: CGRect.zero)
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
    }

    private var keyboardTrackingView: KeyboardTrackingView?

    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        guard let keyboardTrackingView = keyboardTrackingView,
            view != keyboardTrackingView,
            view != backgroundView else { return }
        let offset: CGFloat
        if let adjustable = view as? MarginAdjustable {
            offset = -adjustable.bounceAnimationOffset
        } else {
            offset = 0
        }
        keyboardTrackingView.topAnchor.constraint(
            greaterThanOrEqualTo: view.bottomAnchor,
            constant: offset
        ).with(priority: UILayoutPriority(250)).isActive = true
    }
}
