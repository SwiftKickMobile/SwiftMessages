//
//  Utils.swift
//  Demo
//
//  Created by Timothy Moose on 8/25/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit

extension UILabel {

    func configureBodyTextStyle() {
        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.lineSpacing = 5.0
        attributedText = NSAttributedString(string: text ?? "", attributes: [NSAttributedString.Key.paragraphStyle : bodyStyle])
    }

    func configureCodeStyle(on substring: String?) {
        var attributes: [NSAttributedString.Key : Any] = [:]
        let codeFont = UIFont(name: "CourierNewPSMT", size: font.pointSize)!
        attributes[NSAttributedString.Key.font] = codeFont
        attributes[NSAttributedString.Key.backgroundColor] = UIColor(white: 0.96, alpha: 1)
        attributedText = attributedText?.setAttributes(attributes: attributes, onSubstring: substring)
    }
}

extension NSAttributedString {

    public func setAttributes(attributes: [NSAttributedString.Key : Any], onSubstring substring: String?) -> NSAttributedString {
        let mutableSelf = NSMutableAttributedString(attributedString: self)
        if let substring = substring {
            var range = NSRange()
            repeat {
                let length = mutableSelf.length
                let start = range.location + range.length
                let remainingLength = length - start
                let remainingRange = NSRange(location: start, length: remainingLength)
                range = (mutableSelf.string as NSString).range(of: substring, options: .caseInsensitive, range: remainingRange)
                NSAttributedString.set(attributes: attributes, in: range, of: mutableSelf)
            } while range.length > 0
        } else {
            let range = NSRange(location: 0, length: mutableSelf.length)
            NSAttributedString.set(attributes: attributes, in: range, of: mutableSelf)
        }
        return mutableSelf
    }

    private static func set(attributes newAttributes: [NSAttributedString.Key : Any], in range: NSRange, of mutableString: NSMutableAttributedString) {
        if range.length > 0 {
            var attributes = mutableString.attributes(at: range.location, effectiveRange: nil)
            for (key, value) in newAttributes {
                attributes.updateValue(value, forKey: key)
            }
            mutableString.setAttributes(attributes, range: range)
        }
    }
}
