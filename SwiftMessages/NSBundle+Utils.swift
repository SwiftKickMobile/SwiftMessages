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
        if let path = bundle.path(forResource: "SwiftMessages", ofType: "bundle") {
            return Bundle(path: path)!
        }
        else {
            return bundle
        }
    }
}
