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
        Button("Show message") {
            message = DemoMessage(title: "Demo", body: "This is a sample SwiftUI message! This content should be long enough to wrap.")
        }
        .buttonBorderShape(.roundedRectangle(radius: 15))
        .swiftMessage(message: $message)
    }
}

#Preview {
    DemoView()
}
