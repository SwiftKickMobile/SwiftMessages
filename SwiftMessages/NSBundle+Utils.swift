//
//  NSBundle+Utils.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/8/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import Foundation

extension Bundle {
    static func sm_frameworkBundle() -> Bundle {
        let bundle = Bundle(for: MessageView.self)
        // Check for Swift Package Manager bundle name
        if let path = bundle.path(forResource: "SwiftMessages_SwiftMessages", ofType: "bundle") {
            return Bundle(path: path)!
        }
        // Check for CocoaPods or Carthage bundle name
        else if let path = bundle.path(forResource: "SwiftMessages", ofType: "bundle") {
            return Bundle(path: path)!
        }
        // Just return the app bundle
        else {
            return bundle
        }
    }
}
