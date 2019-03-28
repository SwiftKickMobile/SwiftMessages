//
//  AView.swift
//  Demo
//
//  Created by Hanguang on 2019/3/13.
//  Copyright © 2019 SwiftKick Mobile. All rights reserved.
//

import UIKit
import SwiftMessages

class AView: MessageView {
    var position: CGPoint = .zero {
        didSet {
            var frame = backgroundView.frame
            frame.origin = position
            backgroundView.frame = frame
        }
    }
}
