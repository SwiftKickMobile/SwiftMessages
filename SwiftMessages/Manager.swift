//
//  Manager.swift
//  SwiftMessages
//
//  Created by Tim Moose on 8/1/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

let globalManager = Manager()

class Manager {
    
    var queue: [Presentable] = []
    var current: Presentable? = nil {
        didSet {
            if oldValue != nil {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue(), { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.dequeueNext()
                })
            }
        }
    }
    
    func enqueue(presenter presenter: Presentable) {
        if let identity = presenter.identity {
            if current?.identity == identity { return }
            if queue.filter({ $0.identity == identity }).count > 0 { return }
        }
        queue.append(presenter)
        dequeueNext()
    }
    
    func dequeueNext() {
        guard self.current == nil else { return }
        guard queue.count > 0 else { return }
        let current = queue.removeFirst()
        self.current = current
        do {
            try current.show { [weak self] completed in
                guard let strongSelf = self else { return }
                guard completed else {
                    strongSelf.hide(presenter: current)
                    return
                }
                if let pauseDuration = current.pauseDuration {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(pauseDuration * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue(), {
                        guard let strongSelf = self else { return }
                        strongSelf.hide(presenter: current)
                    })
                } else {
                    strongSelf.hide(presenter: current)
                }
            }
        } catch {
            self.current = nil
        }
    }
    
    func hide(presenter presenter: Presentable) {
        guard let current = current else { return }
        if presenter !== current { return }
        current.hide { [weak self] (completed) in
            guard let strongSelf = self else { return }
            guard completed else { return }
            strongSelf.current = nil
        }
    }
}