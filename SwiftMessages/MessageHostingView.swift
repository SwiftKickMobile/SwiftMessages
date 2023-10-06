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
public class MessageHostingView<Content>: BaseView, Identifiable where Content: View {

    // MARK: - API

    public let id: String

    public init<Message>(message: Message) where Message: MessageViewConvertible, Message.Content == Content {
        let messageView: Content = message.asMessageView()
        hostVC = UIHostingController(rootView: messageView)
        id = message.id
        super.init(frame: .zero)
        hostVC.loadViewIfNeeded()
        installContentView(hostVC.view)
        backgroundColor = .clear
        hostVC.view.backgroundColor = .clear
    }

    // MARK: - Constants

    // MARK: - Variables

    private let hostVC: UIHostingController<Content>

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
