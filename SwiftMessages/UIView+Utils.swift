//
//  UIView+Utils.swift
//  SwiftMessages
//
//  Created by Tim Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

extension UIView {
    
    public class func viewFromNib<T>() throws -> T {
        let name = description().componentsSeparatedByString(".").last
        assert(name != nil)
        let view: T = try viewFromNib(named: name!)
        return view
    }
    
    public class func viewFromNib<T>(named name: String) throws -> T {
        do {
            let view: T = try viewFromNib(named: name, bundle: NSBundle.mainBundle())
            return view
        } catch {
            let view: T = try viewFromNib(named: name, bundle: NSBundle.init(forClass: Manager.self))
            return view
        }
    }
    
    public class func viewFromNib<T>(named name: String, bundle: NSBundle) throws -> T {
        guard let arrayOfViews = NSBundle.mainBundle().loadNibNamed(name, owner: self, options: nil) else { throw Error.CannotLoadNib(nibName: name) }
        guard let view = arrayOfViews.first as? T else { throw Error.CannotLoadViewFromNib(nibName: name) }
        return view
    }
}


