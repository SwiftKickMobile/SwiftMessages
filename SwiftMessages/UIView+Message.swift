//
//  UIView+Message.swift
//  SwiftMessages
//
//  Created by Tim Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

extension UIView {
    
    class func viewFromNib<T>() throws -> T {
        let name = description().componentsSeparatedByString(".").last
        assert(name != nil)
        let view: T? = try viewFromNib(named: name!)
        assert(view != nil)
        return view!
    }
    
    class func viewFromNib<T>(named name: String) throws -> T {
        let arrayOfViews = NSBundle.mainBundle().loadNibNamed(name, owner: self, options: nil)
        guard let view = arrayOfViews.first as? T else { throw Error.CannotLoadViewFromNib(nibName: name) }
        return view
    }
}
