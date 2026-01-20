//
//  DemoMessage.swift
//  SwiftUIDemo
//
//  Created by Timothy Moose on 10/5/23.
//

import SwiftUI
import SwiftMessages

struct DemoMessage: Identifiable {
    let title: String
    let body: String
    let style: DemoMessageView.Style

    var id: String { title + body }
}

extension DemoMessage: MessageViewConvertible {
    func asMessageView() -> DemoMessageView {
        DemoMessageView(message: self, style: style)
    }
}
