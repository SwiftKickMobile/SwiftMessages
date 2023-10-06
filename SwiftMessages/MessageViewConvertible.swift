//
//  MessageViewConvertible.swift
//  SwiftUIDemo
//
//  Created by Timothy Moose on 10/5/23.
//

import SwiftUI

@available(iOS 14.0, *)
/// A protocol used to display a SwiftUI message view using the `swiftMessage()` modifier.
public protocol MessageViewConvertible: Equatable, Identifiable {
    associatedtype Content: View
    func asMessageView() -> Content
}

