//
//  AppDelegate.swift
//  Demo
//
//  Created by Tim Moose on 8/11/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

let brandColor = UIColor(red: 42/255.0, green: 168/255.0, blue: 250/255.0, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window?.tintColor = brandColor
        #if os(iOS)
        UISwitch.appearance().onTintColor = brandColor
        #endif
        return true
    }
}

