//
//  Identifiable.swift
//  SwiftMessages
//
//  Created by Tim Moose on 8/1/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import Foundation

public protocol Identifiable {
    var identity: String { get }
}