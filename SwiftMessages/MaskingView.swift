//
//  MaskingView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 3/11/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit


class MaskingView: PassthroughView {

    private(set) var containerView: UIView!

    func install(keyboardTrackingView: KeyboardTrackingView) {
        // Pin keybaord tracking view to the bottom
        do {
            keyboardTrackingView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(keyboardTrackingView)
            keyboardTrackingView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            keyboardTrackingView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            keyboardTrackingView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
        // Container view
        do {
            containerView = PassthroughView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(containerView)
            containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: keyboardTrackingView.topAnchor).isActive = true
        }
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
        containerView = self
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        containerView = self
        clipsToBounds = true
    }
}
