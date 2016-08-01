//
//  MessagePresenter.swift
//  SwiftMessages
//
//  Created by Tim Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit

enum Container {
    case View(view: UIView)
    case ViewController(viewController: UIViewController)
}

class Presenter<V: UIView> {

    let configuration: Configuration<V>
    var translationConstraint: NSLayoutConstraint! = nil
    var translationOffset: CGFloat = 0
    
    init(configuration: Configuration<V>) {
        self.configuration = configuration
    }
    
    func show() throws {
        let view = try getView()
        configuration.viewConfigurations.forEach { $0(view: view) }
        let container = try getContainer()
        install(view: view, container: container)
        show(view: view, container: container)
    }
    
    func getView() throws -> V {
        if let nibName = configuration.nibName {
            return try V.viewFromNib(named: nibName)
        } else {
            return try V.viewFromNib()
        }
    }
    
    func getContainer() throws -> Container {
        switch configuration.presentationContext {
        case .InKeyWindow:
            guard let window = UIApplication.sharedApplication().keyWindow else { throw Error.CannotFindContainer }
            return .View(view: window)
        case .InWindow(let window):
            return .View(view: window)
        case .OverWindow:
            fatalError()
        case .InViewController(let viewController):
            return .ViewController(viewController: viewController)
        case .InTopViewController:
            fatalError()
        }
        fatalError()
    }
    
    func install(view view: V, container: Container) {
        switch container {
        case .View(let containerView):
            install(view: view, container: containerView, offset: 0)
        case .ViewController(let viewController):
            let containerView = viewController.view // TODO
            let offset = CGFloat(0) // TODO
            install(view: view, container: containerView, offset: offset)
        }
    }
    
    func install(view view: UIView, container: UIView, offset: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        let leading = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: container, attribute: .Leading, multiplier: 1.00, constant: 0)
        let trailing = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: container, attribute: .Trailing, multiplier: 1.00, constant: 0)
        switch configuration.presentationStyle {
        case .Top:
            translationConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: container, attribute: .Top, multiplier: 1.00, constant: offset)
        case .Bottom:
            translationConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: container, attribute: .Bottom, multiplier: 1.00, constant: offset)
        }
        container.addConstraints([leading, trailing, translationConstraint])
        let size = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        translationConstraint.constant -= size.height
        translationOffset = offset
        container.layoutIfNeeded()
    }
    
    func show(view view: V, container: Container) {
        switch configuration.presentationStyle {
        case .Top:
            UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseOut], animations: {
                self.translationConstraint.constant = self.translationOffset
                view.superview!.layoutIfNeeded()
            }, completion: nil)
        case .Bottom:
            translationConstraint.constant = translationOffset
        }
    }
    
    func hide(view view: V, container: Container) {
        
    }
}
