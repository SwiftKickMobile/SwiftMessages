//
//  Manager.swift
//  SwiftMessages
//
//  Created by Tim Moose on 8/1/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

private let globalManager = Manager()

/**
 
 */
public class Manager {
    
    /**
     A default instance of `Manager`.
     */
    public static var sharedManager: Manager {
        return globalManager
    }

    /**
     A block that returns an arbitrary view.
     */
    public typealias ViewProvider = () -> UIView
    
    /**
     Add the given configuration and view, as provided by the `viewProvider` block,
     to the message display queue.
     
     The `viewProvider` block is guaranteed to be called on the main queue where
     it is safe to instantiate and configure the view. This variant of `add` is
     recommended when the message might be added from a background queue given that
     there is no need toexplicitly dispatch back to the main queue.
     
     - parameter configuration: Configuration options for showing the message view.
     - parameter viewProvider: A block that returns an arbitrary view to be displayed as a message.
     */
    public func add(configuration configuration: Configuration, viewProvider: ViewProvider) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let strongSelf = self else { return }
            let view = viewProvider()
            strongSelf.add(configuration: configuration, view: view)
        }
    }

    /**
     Add the given configuration and view to the message display queue.
     - parameter configuration: Configuration options for showing the message view.
     - parameter view: An arbitrary view to be displayed as a message.
     */
    public func add(configuration configuration: Configuration, view: UIView) {
        dispatch_async(syncQueue) { [weak self] in
            guard let strongSelf = self else { return }
            let presenter = Presenter(configuration: configuration, view: view)
            strongSelf.enqueue(presenter: presenter)
        }
    }
    
    /**
     Remove the current message being displayed by animating it away.
     */
    public func remove() {
        dispatch_async(syncQueue) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.removeCurrent()
        }
    }

    /**
     Remove all messages. If a message is currently being displayed,
     it will be animated away.
     */
    public func removeAll() {
        dispatch_async(syncQueue) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.queue.removeAll()
            strongSelf.removeCurrent()
        }
    }

    /**
     Remove a message with the given `id`. If the specified message is
     currently being displayed, it will be animated away. Works with message
     views, such as `MessageView`, that implement the `Identifiable` protocol.
     - parameter id: The identifier of the message to remove.
     */
    public func remove(id: String) {
        dispatch_async(syncQueue) { [weak self] in
            guard let strongSelf = self else { return }
            if id == strongSelf.current?.id {
                strongSelf.removeCurrent()
            }
            strongSelf.queue = strongSelf.queue.filter { $0.id != id }
        }
    }
    
    /**
     The amount of time to pause between removing a message
     and showing the next. Default is 0.5 seconds.
     */
    public var pauseBetweenMessages: NSTimeInterval = 0.5
    
    let syncQueue = dispatch_queue_create("it.swiftkick.SwiftMessage.Manager", DISPATCH_QUEUE_SERIAL)
    var queue: [Presenter] = []
    var current: Presenter? = nil {
        didSet {
            if oldValue != nil {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(pauseBetweenMessages * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, syncQueue, { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.dequeueNext()
                })
            }
        }
    }
    
    func enqueue(presenter presenter: Presenter) {
        if let id = presenter.id {
            if current?.id == id { return }
            if queue.filter({ $0.id == id }).count > 0 { return }
        }
        queue.append(presenter)
        dequeueNext()
    }
    
    func dequeueNext() {
        guard self.current == nil else { return }
        guard queue.count > 0 else { return }
        let current = queue.removeFirst()
        self.current = current
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let strongSelf = self else { return }
            do {
                try current.show { completed in
                    guard let strongSelf = self else { return }
                    guard completed else {
                        dispatch_async(strongSelf.syncQueue, {
                            guard let strongSelf = self else { return }
                            strongSelf.removeCurrent()
                        })
                        return
                    }
                    if let pauseDuration = current.pauseDuration {
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(pauseDuration * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, strongSelf.syncQueue, {
                            guard let strongSelf = self else { return }
                            strongSelf.removeCurrent()
                        })
                    }
                }
            } catch {
                strongSelf.current = nil
            }
        }
    }
    
    func removeCurrent() {
        guard let current = current else { return }
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            current.hide { (completed) in
                guard completed else { return }
                guard let strongSelf = self else { return }
                dispatch_async(strongSelf.syncQueue, {
                    guard let strongSelf = self else { return }
                    strongSelf.current = nil
                })
            }
        }
    }
}