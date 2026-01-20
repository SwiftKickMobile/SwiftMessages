//
//  MessageHostingView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 10/5/23.
//

import SwiftUI
import UIKit

/// A rudimentary hosting view for SwiftUI messages.
@available(iOS 14.0, *)
public class MessageHostingView<Content>: UIView, Identifiable where Content: View {

    // MARK: - API

    public let id: String

    public init(id: String, content: Content) {
        self.id = id
        self.content = { _ in content }
        super.init(frame: .zero)
        backgroundColor = .clear
    }

    public init<Message>(
        message: Message,
        @ViewBuilder content: @escaping (Message, MessageGeometryProxy) -> Content
    ) where Message: Identifiable {
        self.id = message.id
        self.content = { geom in content(message, geom) }
        super.init(frame: .zero)
        backgroundColor = .clear
    }

    convenience public init<Message>(message: Message) where Message: MessageViewConvertible, Message.Content == Content {
        self.init(id: message.id, content: message.asMessageView() )
    }

    // MARK: - Constants

    // MARK: - Variables

    private var hostVC: UIHostingController<Content>?
    private let content: (MessageGeometryProxy) -> Content

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Override hit testing so that only SwiftUI-rendered content inside `MessageHostingView` can receive touches.
    ///
    /// Background:
    /// - `MessageHostingView` does not tightly wrap its SwiftUI content, potentially leaving surrounding regions that should not be tappable. There have
    ///   been some complications with detecting touches on the SwiftUI content over the years that have led to the current approach:
    /// - On iOS 18, UIKit performs a second hit test that resolves to the `UIHostingController`'s view instead of the actual SwiftUI element.
    /// - On iOS 26, the `UIHostingController`'s view no longer contains any subviews, but its `CALayer` *layer* hierarchy still reflects the SwiftUI content.
    ///
    /// All of these issues can be solved by hit testing the layer hierarchy instead of the view hierarchy:
    /// - Call `super.hitTest(point, with: event)` to obtain a candidate view `view`. If our heuristic determines that SwiftUI content was tapped,
    ///   then we return `view` to accept the touch. Otherwise, return `nil` to pass the touch through.
    /// - If the candidate is `MessageHostingView` return `nil`.
    /// - If the candidate is directly parented to `MessageHostingView`, this is the `UIHostingController` view containing the SwiftUI content.
    ///   To determine if SwiftUI content was touched, we iterate over hosting controller's sublayers and return the candidate if the touch intersects a sublayer.
    ///   Otherwise, return `nil`.
    /// - For any other case, we return the candidate because we don't know what's going on.
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        if view == self { return nil }
        
        if view.superview == self {
            for sublayer in view.layer.sublayers ?? [] {
                let sublayerPoint = self.layer.convert(point, to: sublayer)
                if sublayer.contains(sublayerPoint) {
                    return view
                }
            }
            return nil
        }
        return view
    }

    public override func didMoveToSuperview() {
        guard let superview = self.superview else { return }
        let size = superview.bounds.size
        let insets = superview.safeAreaInsets
        let ltr = superview.effectiveUserInterfaceLayoutDirection == .leftToRight
        let proxy = MessageGeometryProxy(
            size: CGSize(
                width: size.width - insets.left - insets.right,
                height: size.height - insets.top - insets.bottom
            ),
            safeAreaInsets: EdgeInsets(
                top: insets.top,
                leading: ltr ? insets.left : insets.right,
                bottom: insets.bottom,
                trailing: ltr ? insets.right : insets.left
            )
        )
        let hostVC = UIHostingController(rootView: content(proxy))
        self.hostVC = hostVC
        hostVC.loadViewIfNeeded()
        installContentView(hostVC.view)
        hostVC.view.backgroundColor = .clear

    }

    // MARK: - Configuration

    private func installContentView(_ contentView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
}
