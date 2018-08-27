//
//  CALayer+Utils.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/3/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import CoreGraphics

extension CALayer {
    func findAnimation(forKeyPath keyPath: String) -> CABasicAnimation? {
        return animationKeys()?
            .compactMap({ animation(forKey: $0) as? CABasicAnimation })
            .filter({ $0.keyPath == keyPath })
            .first
    }
}
