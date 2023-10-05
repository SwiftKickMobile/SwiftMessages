//
//  Identifiable.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/1/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import Foundation

/**
 Message views that adopt the `Identifiable` protocol will have duplicate messages
 removed from the `MessageView` queue. Typically, the `id` would be set to a string
 representation of the content of the message view. For example, `MessageView`, combines
 the title and message body text.
 
 This protocol is optional. Message views that don't adopt `Identifiable` will not
 have duplicates removed.
 */

public protocol Identifiable {
    var id: String { get }
}
