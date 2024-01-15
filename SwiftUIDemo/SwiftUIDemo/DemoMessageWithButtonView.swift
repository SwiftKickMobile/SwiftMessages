//
//  DemoMessageWithButtonView.swift
//  SwiftUIDemo
//
//  Created by Timothy Moose on 1/15/24.
//

import SwiftUI

// A message view with a title, message and button.
struct DemoMessageWithButtonView<Button>: View where Button: View {

    // MARK: - API

    enum Style {
        case standard
        case card
        case tab
    }

    init(message: DemoMessage, style: Style, @ViewBuilder button: @escaping () -> Button) {
        self.message = message
        self.style = style
        self.button = button
    }

    // MARK: - Variables

    let message: DemoMessage
    let style: Style
    @ViewBuilder let button: () -> Button

    // MARK: - Constants

    // MARK: - Body

    var body: some View {
        switch style {
        case .standard:
            content()
                // Mask the content and extend background into the safe area.
                .mask {
                    Rectangle()
                        .edgesIgnoringSafeArea(.top)
                }
        case .card:
            content()
                // Mask the content with a rounded rectangle
                .mask {
                    RoundedRectangle(cornerRadius: 15)
                }
                // External padding around the card
                .padding(10)
        case .tab:
            content()
                // Mask the content with rounded bottom edge and extend background into the safe area.
                .mask {
                    UnevenRoundedRectangle(bottomLeadingRadius: 15, bottomTrailingRadius: 15)
                        .edgesIgnoringSafeArea(.top)
                }
        }
    }

    @ViewBuilder private func content() -> some View {
        VStack() {
            Text(message.title).font(.system(size: 20, weight: .bold))
            Text(message.body)
            button()
        }
        .multilineTextAlignment(.center)
        // Internal padding of the card
        .padding(30)
        // Greedy width
        .frame(maxWidth: .infinity)
        .background(.demoMessageBackground)
    }
}
