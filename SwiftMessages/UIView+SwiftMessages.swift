//
//  UIView+SwiftMessages.swift
//  SwiftMessages
//
//  Created by Tim Moose on 8/12/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import Foundation

extension UIView {

    public class func viewFromNib<T: UIView>() throws -> T {
        let name = description().componentsSeparatedByString(".").last
        assert(name != nil)
        let view: T = try viewFromNib(named: name!, bundle: nil)
        return view
    }

    public class func viewFromNib<T: UIView>(named name: String) throws -> T {
        let view: T = try viewFromNib(named: name, bundle: nil)
        return view
    }
    
    public class func viewFromNib<T: UIView>(named name: String, bundle: NSBundle) throws -> T {
        let view: T = try viewFromNib(named: name, bundle: bundle)
        return view
    }
    
    private class func viewFromNib<T: UIView>(named name: String, bundle: NSBundle? = nil) throws -> T {
        let resolvedBundle: NSBundle
        if let bundle = bundle {
            resolvedBundle = bundle
        } else {
            if NSBundle.mainBundle().pathForResource(name, ofType: "nib") != nil {
                resolvedBundle = NSBundle.mainBundle()
            } else {
                resolvedBundle = NSBundle.frameworkBundle()
            }
        }
        let arrayOfViews = resolvedBundle.loadNibNamed(name, owner: self, options: nil)
        guard let view = arrayOfViews.first as? T else { throw Error.CannotLoadViewFromNib(nibName: name) }
        return view
    }
}