//
//  MessageSizing.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 2/14/21.
//  Copyright © 2021 SwiftKick Mobile. All rights reserved.
//

import Foundation

public protocol MessageSizing {
    func install(sizeableView: MessageSizeable & UIView)
}
