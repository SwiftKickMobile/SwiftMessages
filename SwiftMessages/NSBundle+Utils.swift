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
        let bundle = NSBundle(forClass: MessageView.self)
        if let path = bundle.pathForResource("SwiftMessages", ofType: "bundle") {
            return NSBundle(path: path)!
        }
        else {
            return bundle
        }
    }
}
