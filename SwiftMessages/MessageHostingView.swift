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
        hostVC = UIHostingController(rootView: content)
        self.id = id
        super.init(frame: .zero)
        hostVC.loadViewIfNeeded()
        installContentView(hostVC.view)
        backgroundColor = .clear
        hostVC.view.backgroundColor = .clear
    }

    convenience public init<Message>(message: Message) where Message: MessageViewConvertible, Message.Content == Content {
        self.init(id: message.id, content: message.asMessageView() )
    }

    // MARK: - Constants

    // MARK: - Variables

    private let hostVC: UIHostingController<Content>

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        // The rendered SwiftUI view isn't a direct child of this hosting view. SwiftUI
        // inserts another intermediate view that should also ignore touches.
        if view == self || view?.superview == self { return nil }
        return view
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
