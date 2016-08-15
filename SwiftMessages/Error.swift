//
//  Error.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/7/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import Foundation

enum Error: ErrorType {
    case CannotLoadViewFromNib(nibName: String)
    case NoRootViewController
}
