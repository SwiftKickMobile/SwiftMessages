//
//  Stevia+Center.swift
//  Stevia
//
//  Created by Sacha Durand Saint Omer on 10/02/16.
//  Copyright © 2016 Sacha Durand Saint Omer. All rights reserved.
//

import UIKit

public extension UIView {
    
    /**
     Centers the view in its container.
     
     ```
     button.centerInContainer()
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func centerInContainer() -> UIView {
        if let spv = superview {
            alignCenter(self, with: spv)
        }
        return self
    }
    
    /**
     Centers the view horizontally (X axis) in its container.
     
     ```
     button.centerHorizontally()
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func centerHorizontally() -> UIView {
        if let spv = superview {
            align(vertically: self, spv)
        }
        return self
    }
    
    /**
     Centers the view vertically (Y axis) in its container.
     
     ```
     button.centerVertically()
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func centerVertically() -> UIView {
        if let spv = superview {
            align(horizontally: self, spv)
        }
        return self
    }
    
    /**
     Centers the view horizontally (X axis) in its container, with an offset
     
     ```
     button.centerHorizontally(40)
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func centerHorizontally(_ offset: CGFloat) -> UIView {
        if let spv = superview {
            alignVertically(self, with: spv, offset: offset)
        }
        return self
    }
    
    /**
     Centers the view vertically (Y axis) in its container, with an offset
     
     ```
     button.centerVertically(40)
     ```
     
     - Returns: Itself, enabling chaining,
     
     */
    @discardableResult
    public func centerVertically(_ offset: CGFloat) -> UIView {
        if let spv = superview {
            alignHorizontally(self, with: spv, offset: offset)
        }
        return self
    }
}
