//
//  Error.swift
//  SwiftMessages
//
//  Created by Tim Moose on 8/7/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import Foundation

enum Error: ErrorType {
    case CannotLoadNib(nibName: String)
    case CannotLoadViewFromNib(nibName: String)
    case NoRootViewController
}
