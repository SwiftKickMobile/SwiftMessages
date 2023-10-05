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
        .cornerRadius(15)
        .padding(15)
    }
}

