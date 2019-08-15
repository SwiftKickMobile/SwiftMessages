//
//  UIEdgeInsets+Utils.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 5/23/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    public static func +(left: UIEdgeInsets, right: UIEdgeInsets) -> UIEdgeInsets {
        let topSum = left.top + right.top
        let leftSum = left.left + right.left
        let bottomSum = left.bottom + right.bottom
        let rightSum = left.right + right.right
        return UIEdgeInsets(top: topSum, left: leftSum, bottom: bottomSum, right: rightSum)
    }

    public static func -(left: UIEdgeInsets, right: UIEdgeInsets) -> UIEdgeInsets {
        let topSum = left.top - right.top
        let leftSum = left.left - right.left
        let bottomSum = left.bottom - right.bottom
        let rightSum = left.right - right.right
        return UIEdgeInsets(top: topSum, left: leftSum, bottom: bottomSum, right: rightSum)
    }
}
