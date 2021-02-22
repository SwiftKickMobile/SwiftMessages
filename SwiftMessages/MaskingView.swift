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

class MaskingView: PassthroughView, LayoutInstalling {

    func install(layoutDefiningView: UIView & LayoutDefining) {
        self.layoutDefiningView?.removeFromSuperview()
        self.layoutDefiningView = layoutDefiningView
        layoutDefiningView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(layoutDefiningView)
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
    private var layoutDefiningView: (LayoutDefining & UIView)?

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
        if let layoutDefiningView = layoutDefiningView {
            let layout = layoutDefiningView.layout
            add(insets: layout.insets, relation: .equal)
            add(insets: layout.min.insets, relation: .min)
            add(insets: layout.max.insets, relation: .max)
            add(layoutDefiningView: layoutDefiningView)
        }
        NSLayoutConstraint.activate(cachedConstraints)
    }

    private enum ConstraintRelation {
        case equal
        case min
        case max
    }

    private func add(insets: Layout.Insets, relation: ConstraintRelation) {
        if let top = insets.top { add(top: top, relation: relation) }
        if let bottom = insets.bottom { add(bottom: bottom, relation: relation) }
        if let leading = insets.leading { add(leading: leading, relation: relation) }
        if let trailing = insets.trailing { add(trailing: trailing, relation: relation) }
    }

    private func add(top: Layout.Insets.Dimension, relation: ConstraintRelation) {
        let length: CGFloat
        switch top {
        case .absolute(let dimension, _):
            length = dimension
        case .relative(let percentage, _):
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
        add(
            anchor: messageInsetsGuide.topAnchor,
            otherAnchor: otherAnchor,
            constant: length,
            relation: relation
        )
    }

    private func add(bottom: Layout.Insets.Dimension, relation: ConstraintRelation) {
        let length: CGFloat
        switch bottom {
        case .absolute(let dimension, _):
            length = dimension
        case .relative(let percentage, _):
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
        add(
            anchor: otherAnchor,
            otherAnchor: messageInsetsGuide.bottomAnchor,
            constant: length,
            relation: relation
        )
    }

    private func add(leading: Layout.Insets.Dimension, relation: ConstraintRelation) {
        let length: CGFloat
        switch leading {
        case .absolute(let dimension, _):
            length = dimension
        case .relative(let percentage, _):
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
        add(
            anchor: messageInsetsGuide.leadingAnchor,
            otherAnchor: otherAnchor,
            constant: length,
            relation: relation
        )
    }

    private func add(trailing: Layout.Insets.Dimension, relation: ConstraintRelation) {
        let length: CGFloat
        switch trailing {
        case .absolute(let dimension, _):
            length = dimension
        case .relative(let percentage, _):
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
        add(
            anchor: otherAnchor,
            otherAnchor: messageInsetsGuide.trailingAnchor,
            constant: length,
            relation: relation
        )
    }

    private func add(
        anchor: NSLayoutXAxisAnchor,
        otherAnchor: NSLayoutXAxisAnchor,
        constant: CGFloat,
        relation: ConstraintRelation
    ) {
        let constraint: NSLayoutConstraint
        switch relation {
        case .equal:
            constraint = anchor
                .constraint(equalTo: otherAnchor, constant: constant)
                .with(priority: .messageInsets)
        case .min:
            constraint = anchor
                .constraint(greaterThanOrEqualTo: otherAnchor, constant: constant)
                .with(priority: .messageInsetsBounds)
        case .max:
            constraint = anchor
                .constraint(lessThanOrEqualTo: otherAnchor, constant: constant)
                .with(priority: .messageInsetsBounds)
        }
        cachedConstraints.append(constraint)
    }

    private func add(
        anchor: NSLayoutYAxisAnchor,
        otherAnchor: NSLayoutYAxisAnchor,
        constant: CGFloat,
        relation: ConstraintRelation
    ) {
        let constraint: NSLayoutConstraint
        switch relation {
        case .equal:
            constraint = anchor
                .constraint(equalTo: otherAnchor, constant: constant)
                .with(priority: .messageInsets)
        case .min:
            constraint = anchor
                .constraint(greaterThanOrEqualTo: otherAnchor, constant: constant)
                .with(priority: .messageInsetsBounds)
        case .max:
            constraint = anchor
                .constraint(lessThanOrEqualTo: otherAnchor, constant: constant)
                .with(priority: .messageInsetsBounds)
        }
        cachedConstraints.append(constraint)
    }

    private func add(layoutDefiningView view: LayoutDefining & UIView) {
        cachedConstraints += [
            messageInsetsGuide.topAnchor.constraint(equalTo: view.topAnchor),
            messageInsetsGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageInsetsGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInsetsGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        add(layoutDefiningView: view, size: view.layout.size, relation: .equal)
        add(layoutDefiningView: view, size: view.layout.min.size, relation: .min)
        add(layoutDefiningView: view, size: view.layout.max.size, relation: .max)
        add(layoutDefiningView: view, center: view.layout.center, relation: .equal)
        add(layoutDefiningView: view, center: view.layout.min.center, relation: .min)
        add(layoutDefiningView: view, center: view.layout.max.center, relation: .max)
    }

    private func add(
        layoutDefiningView view: LayoutDefining & UIView,
        size: Layout.Size,
        relation: ConstraintRelation
    ) {
        if let width = size.width {
            let length = self.length(for: width) { $0.width }
            let constraint: NSLayoutConstraint
            switch relation {
            case .equal:
                constraint = view.widthAnchor.constraint(equalToConstant: length)
                    .with(priority: .messageSize)
            case .min:
                constraint = view.widthAnchor.constraint(greaterThanOrEqualToConstant: length)
                    .with(priority: .messageSizeBounds)
            case .max:
                constraint = view.widthAnchor.constraint(lessThanOrEqualToConstant: length)
                    .with(priority: .messageSizeBounds)
            }
            cachedConstraints.append(constraint)
        }
        if let height = size.height {
            let length = self.length(for: height) { $0.height }
            let constraint: NSLayoutConstraint
            switch relation {
            case .equal:
                constraint = view.heightAnchor.constraint(equalToConstant: length)
                    .with(priority: .messageSize)
            case .min:
                constraint = view.heightAnchor.constraint(greaterThanOrEqualToConstant: length)
                    .with(priority: .messageSizeBounds)
            case .max:
                constraint = view.heightAnchor.constraint(lessThanOrEqualToConstant: length)
                    .with(priority: .messageSizeBounds)
            }
            cachedConstraints.append(constraint)
        }
    }


    private func add(
        layoutDefiningView view: LayoutDefining & UIView,
        center: Layout.Center,
        relation: ConstraintRelation
    ) {
        if let x = center.x {
            let length = self.length(for: x) { ($0.minX, $0.maxX) }
            let otherAnchor: NSLayoutXAxisAnchor
            switch x.boundary {
            case .superview: otherAnchor = leadingAnchor
            case .margin: otherAnchor = layoutMarginsGuide.leadingAnchor
            case .safeArea:
                if #available(iOS 11.0, *) {
                    otherAnchor = safeAreaLayoutGuide.leadingAnchor
                } else {
                    otherAnchor = layoutMarginsGuide.leadingAnchor
                }
            }
            let constraint: NSLayoutConstraint
            switch relation {
            case .equal:
                constraint = view.centerXAnchor.constraint(equalTo: otherAnchor, constant: length)
                    .with(priority: .messageCenter)
            case .min:
                constraint = view.centerXAnchor.constraint(
                    greaterThanOrEqualTo: otherAnchor,
                    constant: length
                ).with(priority: .messageSizeBounds)
            case .max:
                constraint = view.centerXAnchor.constraint(
                    lessThanOrEqualTo: otherAnchor,
                    constant: length
                ).with(priority: .messageSizeBounds)
            }
            cachedConstraints.append(constraint)
        }
        if let y = center.y {
            let length = self.length(for: y) { ($0.minY, $0.maxY) }
            let otherAnchor: NSLayoutYAxisAnchor
            switch y.boundary {
            case .superview: otherAnchor = topAnchor
            case .margin: otherAnchor = layoutMarginsGuide.topAnchor
            case .safeArea:
                if #available(iOS 11.0, *) {
                    otherAnchor = safeAreaLayoutGuide.topAnchor
                } else {
                    otherAnchor = layoutMarginsGuide.topAnchor
                }
            }
            let constraint: NSLayoutConstraint
            switch relation {
            case .equal:
                constraint = view.centerYAnchor.constraint(equalTo: otherAnchor, constant: length)
                    .with(priority: .messageCenter)
            case .min:
                constraint = view.centerYAnchor.constraint(
                    greaterThanOrEqualTo: otherAnchor,
                    constant: length
                ).with(priority: .messageSizeBounds)
            case .max:
                constraint = view.centerYAnchor.constraint(
                    lessThanOrEqualTo: otherAnchor,
                    constant: length
                ).with(priority: .messageSizeBounds)
            }
            cachedConstraints.append(constraint)
        }
    }

    private func length(
        for dimension: Layout.Size.Dimension,
        extractor: (CGRect) -> CGFloat
    ) -> CGFloat {
        let insetBounds: CGRect = {
            guard let boundary = dimension.boundary else { return .zero }
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
            return bounds.inset(by: insets)
        }()
        switch dimension {
        case .absolute(let dimension):
            return dimension
        case .relative(let percentage, _):
            return extractor(insetBounds) * percentage
        case .absoluteInsets(let dimension, _):
            return extractor(insetBounds) - dimension * 2
        }
    }

    private func length(
        for dimension: Layout.Center.Dimension,
        extractor: (CGRect) -> (CGFloat, CGFloat)
    ) -> CGFloat {
        let insets: UIEdgeInsets
        switch dimension.boundary {
        case .superview: insets = .zero
        case .margin: insets = layoutMargins
        case .safeArea:
            if #available(iOS 11.0, *) {
                insets = safeAreaInsets
            } else {
                insets = layoutMargins
            }
        }
        let insetBounds = bounds.inset(by: insets)
        switch dimension {
        case .absolute(let dimension, _):
            let (min, _) = extractor(insetBounds)
            return min + dimension
        case .relative(let percentage, _):
            let (min, max) = extractor(insetBounds)
            return min + (max - min) * percentage
        }
    }
}
