//
//  NSBundle+Utils.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/8/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import Foundation

private class BundleToken {}

extension Bundle {
    // This is copied method from SPM generated Bundle.module for CocoaPods support
    static func sm_frameworkBundle() -> Bundle {

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleToken.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        // Search for SPM bundle
        let bundleName = "SwiftMessages_SwiftMessages"
        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        // Search for CocoaPods/Carthage bundle
        let cocoaPodsBundleName = "SwiftMessages"
        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(cocoaPodsBundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named SwiftMessages_SwiftMessages or SwiftMessages")
    }
}
