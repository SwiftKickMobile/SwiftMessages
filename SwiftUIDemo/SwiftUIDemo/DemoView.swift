//
//  DemoView.swift
//  SwiftUIDemo
//
//  Created by Timothy Moose on 10/5/23.
//

import SwiftUI
import SwiftMessages

struct DemoView: View {
    
    /// Use this to manually hide the swift message
    @Environment(\.swiftMessagesHide) private var hide

    /// Demonstrates purely data-driven message presentation.
    @State var message: DemoMessage?

    /// Demonstrates message presentation with a view builder.
    @State var messageWithButton: DemoMessage?

    var body: some View {
        VStack {
            Button("Show standard message") {
                message = DemoMessage(
                    title: "Demo",
                    body: "This is a sample SwiftUI card-style message! This content should be long enough to wrap.",
                    style: .standard
                )
            }
            Button("Show card message") {
                message = DemoMessage(
                    title: "Demo",
                    body: "This is a sample SwiftUI card-style message! This content should be long enough to wrap.",
                    style: .card
                )
            }
            Button("Show tab message") {
                message = DemoMessage(
                    title: "Demo",
                    body: "This is a sample SwiftUI card-style message! This content should be long enough to wrap.",
                    style: .tab
                )
            }
            Button("Show message with button") {
                messageWithButton = DemoMessage(
                    title: "Demo",
                    body: "This message view has a button was constructed with a view builder.",
                    style: .card
                )
            }
        }
        .buttonStyle(.bordered)
        .swiftMessage(message: $message)
        .swiftMessage(message: $messageWithButton) { message in
            DemoMessageWithButtonView(message: message, style: .card) {
                Button("Hide") {
                    hide(animated: true)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    DemoView()
}
