//
//  NSBundle+Utils.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/8/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import Foundation

extension NSBundle {
    static func sm_frameworkBundle() -> NSBundle {
        let path = NSBundle(forClass: MessageView.self).pathForResource("SwiftMessages", ofType: "bundle")!
        return NSBundle(path: path)!
    }
}