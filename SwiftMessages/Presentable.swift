//
//  Presentable.swift
//  SwiftMessages
//
//  Created by Tim Moose on 8/1/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import Foundation

protocol Presentable: class {
    var identity: String? { get }
    var pauseDuration: NSTimeInterval? { get }
    func show(completion completion: (completed: Bool) -> Void) throws
    func hide(completion completion: (completed: Bool) -> Void)
}