//
//  MessagePresenter.swift
//  SwiftMessages
//
//  Created by Tim Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}

//class TypeErasing {
//    var value: Any
//    init (
//}

enum Container {
    case View(view: Weak<UIView>)
    case ViewController(viewController: Weak<UIViewController>)
    case OverWindow(viewController: OverWindowViewController)
}

class Presenter<V: UIView>: Presentable {

    let configuration: Configuration<V>
    let view: V
    var translationConstraint: NSLayoutConstraint! = nil
    var container: Container!
    var showTranslationOffset: CGFloat = 0
    
    init(configuration: Configuration<V>, view: V) {
        self.configuration = configuration
        self.view = view
    }
    
    var identity: String? {
        let identifiable = view as? Identifiable
        return identifiable?.identity
    }
    
    var pauseDuration: NSTimeInterval? {
        let duration: NSTimeInterval?
        switch self.configuration.duration {
        case .Automatic:
            duration = 2.0
        case .Seconds(let seconds):
            duration = seconds
        case .Forever:
            duration = nil
        }
        return duration
    }
    
    func show(completion completion: (completed: Bool) -> Void) throws {
        container = try getContainer()
        configuration.viewConfigurations.forEach { $0(view: view) }
        install()
        showAnimation(completion: completion)
    }
    
    func getContainer() throws -> Container {
        switch configuration.presentationContext {
        case .InKeyWindow:
            guard let window = UIApplication.sharedApplication().keyWindow else { throw Error.CannotFindContainer }
            return .View(view: Weak(value: window))
        case .InWindow(let window):
            return .View(view: Weak(value: window))
        case .OverWindow(let level):
            let viewController = OverWindowViewController(windowLevel: level)
            viewController.statusBarStyle = configuration.preferredStatusBarStyle
            return .OverWindow(viewController: viewController)
        case .InViewController(let viewController):
            return .ViewController(viewController: Weak(value: viewController))
        case .InTopViewController:
            fatalError()
        }
        fatalError()
    }
    
    func install() {
        
        func install(view view: UIView, containerView: UIView) {
            view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(view)
            let leading = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: containerView, attribute: .Leading, multiplier: 1.00, constant: 0.0)
            let trailing = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: containerView, attribute: .Trailing, multiplier: 1.00, constant: 0.0)
            switch configuration.presentationStyle {
            case .Top:
                translationConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.00, constant: 0.0)
            case .Bottom:
                translationConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.00, constant: 0.0)
            }
            containerView.addConstraints([leading, trailing, translationConstraint])
            let size = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            translationConstraint.constant -= size.height
            containerView.layoutIfNeeded()
        }
        
        switch container! {
        case .View(let containerView):
            guard let value = containerView.value else { return }
            install(view: view, containerView: value)
            showTranslationOffset = 0.0
        case .ViewController(let viewController):
            guard let value = viewController.value else { return }
            let containerView = value.view // TODO
            install(view: view, containerView: containerView)
            showTranslationOffset = 0.0 // TODO
        case .OverWindow(let viewController):
            viewController.install()
            let containerView = viewController.view
            install(view: view, containerView: containerView)
            showTranslationOffset = 0.0
        }
    }
    
    func showAnimation(completion completion: (completed: Bool) -> Void) {
        switch configuration.presentationStyle {
        case .Top, .Bottom:
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.BeginFromCurrentState, .CurveLinear, .AllowUserInteraction], animations: {
                self.translationConstraint.constant = self.showTranslationOffset - 5.0 // compensate for bounce overshoot
                self.view.superview?.layoutIfNeeded()
            }, completion: { completed in
                completion(completed: completed)
            })
        }
    }
    
    func hide(completion completion: (completed: Bool) -> Void) {
        switch configuration.presentationStyle {
        case .Top, .Bottom:
            UIView.animateWithDuration(0.25, delay: 0, options: [.BeginFromCurrentState, .CurveEaseIn], animations: {
                let size = self.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                self.translationConstraint.constant -= size.height
                self.view.superview?.layoutIfNeeded()
            }, completion: { completed in
                switch self.container! {
                case .OverWindow(let viewController):
                    viewController.uninstall()
                default:
                    break
                }
                completion(completed: completed)
            })
        }
    }
}
