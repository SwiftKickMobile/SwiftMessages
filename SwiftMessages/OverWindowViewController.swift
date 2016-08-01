//
//  OverWindowViewController.swift
//  SwiftMessages
//
//  Created by Tim Moose on 8/1/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

class OverWindowViewController: UIViewController
{
    private var window: UIWindow?
    
    init(windowLevel: UIWindowLevel = UIWindowLevelNormal)
    {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window = window
        super.init(nibName: nil, bundle: nil)
        window.rootViewController = self
        window.windowLevel = windowLevel
    }
    
    func install() {
        guard let window = window else { return }
        window.makeKeyAndVisible()
    }
    
    func uninstall() {
        window?.hidden = true
        window = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}