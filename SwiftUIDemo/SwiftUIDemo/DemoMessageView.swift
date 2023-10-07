//
//  DemoMessageView.swift
//  SwiftUIDemo
//
//  Created by Timothy Moose on 10/5/23.
//

import SwiftUI

struct DemoMessageView: View {

    // MARK: - API

    let message: DemoMessage

    // MARK: - Variables

    // MARK: - Constants

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading) {
            Text(message.title).font(.system(size: 20, weight: .bold))
            Text(message.body)
        }
        .multilineTextAlignment(.leading)
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(.demoMessageBackground)
        // This makes a tab-style view where the bottom corners are rounded and the view's background
        // extends to the top edge.
        .mask(
            UnevenRoundedRectangle(
                cornerRadii: .init(bottomLeading: 15, bottomTrailing: 15)
            )
            .edgesIgnoringSafeArea(.top)
        )
    }
}
