//
//  UIView+Utils.swift
//  SwiftMessages
//
//  Created by Tim Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

extension UIView {
    
    public class func viewFromNib<T>(bundle bundle: NSBundle? = nil) throws -> T {
        let name = description().componentsSeparatedByString(".").last
        assert(name != nil)
        let view: T = try viewFromNib(named: name!, bundle: bundle)
        return view
    }
    
    public class func viewFromNib<T>(named name: String, bundle: NSBundle? = nil) throws -> T {
        let resolvedBundle: NSBundle
        if let bundle = bundle {
            resolvedBundle = bundle
        } else {
            resolvedBundle = NSBundle.frameworkBundle()
        }
        guard let arrayOfViews = resolvedBundle.loadNibNamed(name, owner: self, options: nil) else { throw Error.CannotLoadNib(nibName: name) }
        guard let view = arrayOfViews.first as? T else { throw Error.CannotLoadViewFromNib(nibName: name) }
        return view
    }
}


