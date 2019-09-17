//
//  WindowViewController.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/1/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

open class WindowViewController: UIViewController
{
    fileprivate var window: UIWindow?
    
    let windowLevel: UIWindow.Level
    let config: SwiftMessages.Config
    
    override open var shouldAutorotate: Bool {
        return config.shouldAutorotate
    }
    
    public init(windowLevel: UIWindow.Level?, config: SwiftMessages.Config)
    {
        self.windowLevel = windowLevel ?? UIWindow.Level.normal
        self.config = config
        let window = PassthroughWindow(frame: UIScreen.main.bounds)
        self.window = window
        super.init(nibName: nil, bundle: nil)
        self.view = PassthroughView()
        window.rootViewController = self
        window.windowLevel = windowLevel ?? UIWindow.Level.normal
    }
    
    func install(becomeKey: Bool) {
        guard let window = window else { return }
        if becomeKey {
            window.makeKeyAndVisible()
        } else {
            window.isHidden = false
        }
    }

    @available(iOS 13, *)
    func install(becomeKey: Bool, scene: UIWindowScene?) {
        guard let window = window else { return }
        window.windowScene = scene
        if becomeKey {
            window.makeKeyAndVisible()
        } else {
            window.isHidden = false
        }
    }
    
    func uninstall() {
        window?.isHidden = true
        window = nil
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return config.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }

    open override var prefersStatusBarHidden: Bool {
        return config.prefersStatusBarHidden ?? super.prefersStatusBarHidden
    }
}

extension WindowViewController {
    static func newInstance(windowLevel: UIWindow.Level?, config: SwiftMessages.Config) -> WindowViewController {
        return config.windowViewController?(windowLevel, config) ?? WindowViewController(windowLevel: windowLevel, config: config)
    }
}
