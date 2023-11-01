//
//  DemoView.swift
//  SwiftUIDemo
//
//  Created by Timothy Moose on 10/5/23.
//

import SwiftUI
import SwiftMessages

struct DemoView: View {

    @State var message: DemoMessage?

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
        }
        .buttonStyle(.bordered)
        .swiftMessage(message: $message)
    }
}

#Preview {
    DemoView()
}
