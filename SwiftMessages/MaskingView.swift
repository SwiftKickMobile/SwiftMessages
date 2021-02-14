//
//  MaskingView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 3/11/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

// TODO SIZE - need a version of this logic to limit views to 500pt on regular size class by default.
//        regularWidthLayoutConstraints = [
//            backgroundView.leftAnchor.constraint(
//                greaterThanOrEqualTo: layoutMarginsGuide.leftAnchor,
//                constant: insets.left
//            ).with(priority: .belowMessageSizeable),
//            backgroundView.rightAnchor.constraint(
//                lessThanOrEqualTo: layoutMarginsGuide.rightAnchor,
//                constant: -insets.right
//            ).with(priority: .belowMessageSizeable),
//            backgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: 500)
//                .with(priority: .belowMessageSizeable),
//            backgroundView.widthAnchor.constraint(equalToConstant: 500)
//                .with(priority: UILayoutPriority(rawValue: 200)),
//        ]

class MaskingView: PassthroughView, MessageSizing {

    func install(sizeableView: MessageSizeable & UIView) {
        self.sizeableView?.removeFromSuperview()
        self.sizeableView = sizeableView
        sizeableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sizeableView)
        setNeedsUpdateConstraints()
    }

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
        postInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }

    private func postInit() {
        clipsToBounds = true
        addLayoutGuide(messageInsetsGuide)
    }

    override var bounds: CGRect {
        didSet {
            guard bounds != oldValue else { return }
            setNeedsUpdateConstraints()
        }
    }

    private var keyboardTrackingView: KeyboardTrackingView?
    private var cachedConstraints: [NSLayoutConstraint] = []
    private let messageInsetsGuide = UILayoutGuide()
    private var sizeableView: (MessageSizeable & UIView)?

    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        guard let keyboardTrackingView = keyboardTrackingView,
            view != keyboardTrackingView,
            view != backgroundView else { return }
        keyboardTrackingView.topAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor).with(priority: UILayoutPriority(250)).isActive = true
    }

    override func updateConstraints() {
        super.updateConstraints()
        NSLayoutConstraint.deactivate(cachedConstraints)
        cachedConstraints = []
        if let top = sizeableView?.messageInsets.top { update(top: top) }
        if let bottom = sizeableView?.messageInsets.bottom { update(bottom: bottom) }
        if let leading = sizeableView?.messageInsets.leading { update(leading: leading) }
        if let trailing = sizeableView?.messageInsets.trailing { update(trailing: trailing) }
        if let sizeableView = sizeableView { update(sizeableView: sizeableView) }
        NSLayoutConstraint.activate(cachedConstraints)
    }

    private func update(top: MessageInsets.Dimension) {
        let length: CGFloat
        switch top {
        case .absoluteMargin(let dimension, _):
            length = dimension
        case .relativeMargin(let percentage, _):
            length = bounds.height * percentage
        }
        let otherAnchor: NSLayoutYAxisAnchor
        switch top.boundary {
        case .superview: otherAnchor = topAnchor
        case .margin: otherAnchor = layoutMarginsGuide.topAnchor
        case .safeArea:
            if #available(iOS 11.0, *) {
                otherAnchor = safeAreaLayoutGuide.topAnchor
            } else {
                otherAnchor = layoutMarginsGuide.topAnchor
            }
        }
        cachedConstraints.append(
            messageInsetsGuide.topAnchor.constraint(equalTo: otherAnchor, constant: length)
                .with(priority: .messageInset)
        )
    }

    private func update(bottom: MessageInsets.Dimension) {
        let length: CGFloat
        switch bottom {
        case .absoluteMargin(let dimension, _):
            length = dimension
        case .relativeMargin(let percentage, _):
            length = bounds.height * percentage
        }
        let otherAnchor: NSLayoutYAxisAnchor
        switch bottom.boundary {
        case .superview: otherAnchor = bottomAnchor
        case .margin: otherAnchor = layoutMarginsGuide.bottomAnchor
        case .safeArea:
            if #available(iOS 11.0, *) {
                otherAnchor = safeAreaLayoutGuide.bottomAnchor
            } else {
                otherAnchor = layoutMarginsGuide.bottomAnchor
            }
        }
        cachedConstraints.append(
            messageInsetsGuide.bottomAnchor.constraint(equalTo: otherAnchor, constant: -length)
                .with(priority: .messageInset)
        )
    }

    private func update(leading: MessageInsets.Dimension) {
        let length: CGFloat
        switch leading {
        case .absoluteMargin(let dimension, _):
            length = dimension
        case .relativeMargin(let percentage, _):
            length = bounds.width * percentage
        }
        let otherAnchor: NSLayoutXAxisAnchor
        switch leading.boundary {
        case .superview: otherAnchor = leadingAnchor
        case .margin: otherAnchor = layoutMarginsGuide.leadingAnchor
        case .safeArea:
            if #available(iOS 11.0, *) {
                otherAnchor = safeAreaLayoutGuide.leadingAnchor
            } else {
                otherAnchor = layoutMarginsGuide.leadingAnchor
            }
        }
        cachedConstraints.append(
            messageInsetsGuide.leadingAnchor.constraint(equalTo: otherAnchor, constant: length)
                .with(priority: .messageInset)
        )
    }

    private func update(trailing: MessageInsets.Dimension) {
        let length: CGFloat
        switch trailing {
        case .absoluteMargin(let dimension, _):
            length = dimension
        case .relativeMargin(let percentage, _):
            length = bounds.width * percentage
        }
        let otherAnchor: NSLayoutXAxisAnchor
        switch trailing.boundary {
        case .superview: otherAnchor = trailingAnchor
        case .margin: otherAnchor = layoutMarginsGuide.trailingAnchor
        case .safeArea:
            if #available(iOS 11.0, *) {
                otherAnchor = safeAreaLayoutGuide.trailingAnchor
            } else {
                otherAnchor = layoutMarginsGuide.trailingAnchor
            }
        }
        cachedConstraints.append(
            messageInsetsGuide.trailingAnchor.constraint(equalTo: otherAnchor, constant: -length)
                .with(priority: .messageInset)
        )
    }

    private func update(sizeableView view: MessageSizeable & UIView) {
        cachedConstraints += [
            messageInsetsGuide.topAnchor.constraint(equalTo: view.topAnchor),
            messageInsetsGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageInsetsGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInsetsGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        if let width = view.messageSize.width {
            let length = self.length(for: width, extractor: { $0.width })
            cachedConstraints.append(
                view.widthAnchor.constraint(equalToConstant: length)
                    .with(priority: .messageSize)
            )
        }
        if let height = view.messageSize.height {
            let length = self.length(for: height, extractor: { $0.height })
            cachedConstraints.append(
                view.heightAnchor.constraint(equalToConstant: length)
                    .with(priority: .messageSize)
            )
        }
    }

    private func length(
        for dimension: MessageSize.Dimension,
        extractor: (CGRect) -> CGFloat
    ) -> CGFloat {
        switch dimension {
        case .absolute(let dimension):
            return dimension
        case .absoluteMargin(let margin, let boundary):
            let insets: UIEdgeInsets
            switch boundary {
            case .superview: insets = .zero
            case .margin: insets = layoutMargins
            case .safeArea:
                if #available(iOS 11.0, *) {
                    insets = safeAreaInsets
                } else {
                    insets = layoutMargins
                }
            }
            return extractor(bounds.inset(by: insets)) - margin * 2
        case .relative(let percentage, let boundary):
            let insets: UIEdgeInsets
            switch boundary {
            case .superview: insets = .zero
            case .margin: insets = layoutMargins
            case .safeArea:
                if #available(iOS 11.0, *) {
                    insets = safeAreaInsets
                } else {
                    insets = layoutMargins
                }
            }
            return extractor(bounds.inset(by: insets)) * percentage
        }
    }
}
