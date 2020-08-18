//
//  PassthroughWindow.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 8/5/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

class PassthroughWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // iOS has started embedding the SwiftMessages view in private views that block
        // interaction with views underneath, essentially making the window behave like a modal.
        // To work around this, we'll ignore hit test results on these views.
        let view = super.hitTest(point, with: event)
        if let view = view,
            let hitTestView = hitTestView,
            hitTestView.isDescendant(of: view) && hitTestView != view {
            return nil
        }
        return view
    }

    init(hitTestView: UIView) {
        self.hitTestView = hitTestView
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var hitTestView: UIView?
}
