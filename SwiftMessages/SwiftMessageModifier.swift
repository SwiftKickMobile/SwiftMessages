//
//  SwiftMessageModifier.swift
//  SwiftUIDemo
//
//  Created by Timothy Moose on 10/5/23.
//

import SwiftUI

@available(iOS 14.0, *)
public extension View {
    /// A state-based modifier for displaying a message.
    func swiftMessage<Message>(
        message: Binding<Message?>,
        config: SwiftMessages.Config? = nil,
        swiftMessages: SwiftMessages? = nil
    ) -> some View where Message: MessageViewConvertible {
        modifier(SwiftMessageModifier(message: message, config: config, swiftMessages: swiftMessages))
    }
}

@available(iOS 14.0, *)
private struct SwiftMessageModifier<Message>: ViewModifier where Message: MessageViewConvertible {
    // MARK: - API

    fileprivate init(
        message: Binding<Message?>,
        config: SwiftMessages.Config? = nil,
        swiftMessages: SwiftMessages? = nil
    ) {
        _message = message
        self.config = config
        self.swiftMessages = swiftMessages
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var message: Message?
    private let config: SwiftMessages.Config?
    private let swiftMessages: SwiftMessages?

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onChange(of: message) { _ in
                if let message {
                    let show: (SwiftMessages.Config, UIView) -> Void = swiftMessages?.show(config:view:) ?? SwiftMessages.show(config:view:)
                    let view = MessageHostingView(message: message)
                    var config = config ?? swiftMessages?.defaultConfig ?? SwiftMessages.defaultConfig
                    config.eventListeners.append { event in
                        if case .didHide = event, event.id == self.message?.id {
                            self.message = nil
                        }
                    }
                    show(config, view)
                }
            }
    }
}
