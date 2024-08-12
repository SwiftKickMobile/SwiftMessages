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

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        // Touches should pass through unless they land on a view that is rendering a SwiftUI element.
        if view == self { return nil }
        // In iOS 18 beta, the hit testing behavior changed in a weird way: when a SwiftUI element is tapped,
        // the first hit test returns the view that renders the SwiftUI element. However, a second identical hit
        // test is performed(!) and on the second test, the `UIHostingController`'s view is returned. We want touches
        // to pass through that view. In iOS 17, we would just return `nil` in that case. However, in iOS 18, the
        // second hit test is actuall essential to touches being delivered to the SwiftUI elements. The new approach
        // is to iterate overall all of the subviews, which are all presumably rendering SwiftUI elements, and
        // only return `nil` if the point is not inside any of these subviews.
        if view.superview == self {
            for subview in view.subviews {
                let subviewPoint = self.convert(point, to: subview)
                if subview.point(inside: subviewPoint, with: event) {
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
