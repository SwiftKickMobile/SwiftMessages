//
//  CustomAnimation.swift
//  Demo
//
//  Created by Hanguang on 2019/3/28.
//  Copyright © 2019 SwiftKick Mobile. All rights reserved.
//

import UIKit
import SwiftMessages

public class CustomAnimation: NSObject, Animator {
    enum ArrowDirection {
        case up
        case down
    }
    
    public var margin: CGFloat = 4
    public var arrowWidth: CGFloat = 8
    public var arrowHeight: CGFloat = 10
    
    weak public var delegate: AnimationDelegate?
    weak var messageView: UIView?
    weak var containerView: UIView?
    var context: AnimationContext?
    
    private lazy var menuView: UIView = {
        return UIView()
    }()
    private lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    private var arrowDirection: ArrowDirection = .up
    var containerSize: CGSize {
        return containerView?.frame.size ?? .zero
    }
    var cornerRadius: CGFloat = 15.0
    var popoverFrame: CGRect?
    var popoverView: UIView?
    var fillColor: CGColor? = UIColor.white.cgColor
    var strokeColor: CGColor?
    var lineWidth: CGFloat = 0
    
    public override init() {}
    
    init(delegate: AnimationDelegate) {
        self.delegate = delegate
    }
    
    public func show(context: AnimationContext, completion: @escaping AnimationCompletion) {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustMargins), name: UIDevice.orientationDidChangeNotification, object: nil)
        install(context: context)
        showAnimation(context: context, completion: completion)
    }
    
    public func hide(context: AnimationContext, completion: @escaping AnimationCompletion) {
        NotificationCenter.default.removeObserver(self)
        let view = menuView
        self.context = context
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            view.alpha = 1
            view.transform = CGAffineTransform.identity
            completion(true)
        }
        UIView.animate(withDuration: hideDuration!, delay: 0, options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], animations: {
            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
        UIView.animate(withDuration: hideDuration!, delay: 0, options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], animations: {
            view.alpha = 0
        }, completion: nil)
        CATransaction.commit()
    }
    
    public var showDuration: TimeInterval? { return 0.5  }
    public var hideDuration: TimeInterval? { return 0.15  }
    
    func install(context: AnimationContext) {
        let view = context.messageView
        let container = context.containerView
        
        if let view = view as? MessageView,
            let bg = view.backgroundView as? CornerRoundingView {
            cornerRadius = bg.cornerRadius
        }
        
        menuView.bounds = view.bounds
        messageView = context.messageView
        containerView = container
        self.context = context
        
        // add view
        container.sv(
            menuView.sv(view)
        )
        
        // position
        let values = preparedValues()
        menuView.frame = values.menuFrame
        arrowDirection = values.arrowDirection
        
        // draw background layer
        installBackgroundLayer(menuView, point: values.arrowPoint)
        
        // install anchor
        let offset = installAnchorPoint(menuView, point: values.arrowPoint)
        
        container.layout(
            offset.y,
            |-offset.x-menuView
        )
        
        // size
        menuView.width(values.menuFrame.width)
        menuView.height(values.menuFrame.height)
        view.fillHorizontally()
        if arrowDirection == .up {
            view.top(arrowHeight)
            view.bottom(0)
        } else {
            view.bottom(arrowHeight)
            view.top(0)
        }
        
        container.layoutIfNeeded()
        adjustMargins()
        container.layoutIfNeeded()
    }
    
    @objc public func adjustMargins() {
        guard let adjustable = menuView as? MarginAdjustable & UIView,
            let context = context else { return }
        adjustable.preservesSuperviewLayoutMargins = false
        if #available(iOS 11, *) {
            adjustable.insetsLayoutMarginsFromSafeArea = false
        }
        adjustable.layoutMargins = adjustable.defaultMarginAdjustment(context: context)
    }
    
    func showAnimation(context: AnimationContext, completion: @escaping AnimationCompletion) {
        let view = menuView
        view.alpha = 0.25
        view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion(true)
        }
        UIView.animate(withDuration: showDuration!, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            view.transform = CGAffineTransform.identity
        }, completion: nil)
        UIView.animate(withDuration: 0.3 * showDuration!, delay: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            view.alpha = 1
        }, completion: nil)
        CATransaction.commit()
    }
}

extension CustomAnimation {
    func preparedValues() -> (arrowPoint: CGPoint,
        arrowDirection: ArrowDirection,
        menuFrame: CGRect) {
            var senderRect: CGRect = .zero
            var arrowDirection: ArrowDirection = .up
            var arrowPoint: CGPoint = .zero
            var menuOffsetX: CGFloat = 0
            var menuFrame: CGRect = menuView.frame
            
            // sender rect
            if let frame = popoverFrame {
                senderRect = frame
            } else if let view = popoverView,
                let superView = view.superview {
                senderRect = superView.convert(view.frame, to: containerView)
            }
            senderRect.origin.y = min(containerSize.height, senderRect.origin.y)
            
            // arrow direction
            if senderRect.midY < containerSize.height/2 {
                arrowDirection = .up
            } else {
                arrowDirection = .down
            }
            
            // arrow point
            arrowPoint = CGPoint(x: senderRect.midX, y: 0)
            let menuSize = menuView.frame.size
            let menuCenterX = menuSize.width/2 + margin
            if senderRect.midY < containerSize.height/2 {
                arrowPoint.y = 0
            } else {
                arrowPoint.y = menuSize.height+arrowHeight
            }
            if arrowPoint.x+menuCenterX > containerSize.width {
                arrowPoint.x = min(
                    arrowPoint.x-(containerSize.width-menuSize.width-margin),
                    menuSize.width-arrowWidth-margin
                )
            } else if arrowPoint.x-menuCenterX < 0 {
                arrowPoint.x = max(
                    cornerRadius+arrowWidth,
                    arrowPoint.x-margin
                )
            } else {
                arrowPoint.x = menuSize.width/2
            }
            
            // menu offset x
            var senderCenterX = senderRect.midX
            if senderRect.midX+menuCenterX > containerSize.width {
                senderCenterX = min(
                    senderCenterX-(containerSize.width-menuSize.width-margin),
                    menuSize.width-arrowWidth-margin
                )
                menuOffsetX = containerSize.width-menuSize.width-margin
            } else if senderCenterX-menuCenterX < 0 {
                senderCenterX = max(
                    cornerRadius+arrowWidth,
                    senderCenterX-margin
                )
                menuOffsetX = margin
            } else {
                senderCenterX = menuSize.width/2
                menuOffsetX = senderRect.midX - menuSize.width/2
            }
            
            // menu frame
            if arrowDirection == .up {
                menuFrame = CGRect(
                    x: menuOffsetX,
                    y: senderRect.maxY,
                    width: menuSize.width,
                    height: menuSize.height+arrowHeight
                )
                if (menuFrame.maxY > containerSize.height) {
                    menuFrame = CGRect(
                        x: menuOffsetX,
                        y: senderRect.maxY,
                        width: menuSize.width,
                        height: containerSize.height-menuFrame.origin.y-margin
                    )
                }
            } else {
                menuFrame = CGRect(
                    x: menuOffsetX,
                    y: senderRect.origin.y-menuSize.height-arrowHeight,
                    width: menuSize.width,
                    height: menuSize.height+arrowHeight
                )
                if menuFrame.origin.y < 0 {
                    menuFrame = CGRect(
                        x: menuOffsetX,
                        y: margin,
                        width: menuSize.width,
                        height: senderRect.origin.y-margin
                    )
                }
            }
            
            return (arrowPoint, arrowDirection, menuFrame)
    }
    
    func installBackgroundLayer(_ view: UIView, point: CGPoint) {
        backgroundLayer.removeFromSuperlayer()
        backgroundLayer.path = backgroundPath(view, arrowPoint: point).cgPath
        backgroundLayer.fillColor = fillColor
        backgroundLayer.strokeColor = strokeColor
        backgroundLayer.lineWidth = lineWidth
        
        // read shadow from message view
        if let messageView = messageView as? MessageView {
            backgroundLayer.shadowColor = messageView.layer.shadowColor
            backgroundLayer.shadowOffset = messageView.layer.shadowOffset
            backgroundLayer.shadowOpacity = messageView.layer.shadowOpacity
            backgroundLayer.masksToBounds = messageView.layer.masksToBounds
            backgroundLayer.shouldRasterize = true
            backgroundLayer.rasterizationScale = UIScreen.main.scale
            messageView.layer.shadowOpacity = 0.0
        }
        
        view.layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    func backgroundPath(_ view: UIView, arrowPoint: CGPoint) -> UIBezierPath {
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        let radius: CGFloat = cornerRadius
        
        let path = UIBezierPath()
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        
        if arrowDirection == .up {
            path.move(to: CGPoint(
                x: arrowPoint.x-arrowWidth,
                y: arrowHeight)
            )
            path.addLine(to: CGPoint(x: arrowPoint.x, y: 0))
            path.addLine(to: CGPoint(
                x: arrowPoint.x+arrowWidth,
                y: arrowHeight)
            )
            path.addLine(to: CGPoint(
                x: viewWidth-radius,
                y: arrowHeight)
            )
            path.addArc(
                withCenter: CGPoint(
                    x: viewWidth-radius,
                    y: arrowHeight+radius
                ),
                radius: radius,
                startAngle: .pi/2*3,
                endAngle: 0,
                clockwise: true
            )
            path.addLine(to: CGPoint(x: viewWidth, y: viewHeight-radius))
            path.addArc(
                withCenter: CGPoint(
                    x: viewWidth-radius,
                    y: viewHeight-radius),
                radius: radius,
                startAngle: 0,
                endAngle: .pi/2,
                clockwise: true
            )
            path.addLine(to: CGPoint(x: radius, y: viewHeight))
            path.addArc(
                withCenter: CGPoint(
                    x: radius,
                    y: viewHeight-radius),
                radius: radius,
                startAngle: .pi / 2,
                endAngle: .pi,
                clockwise: true
            )
            path.addLine(to: CGPoint(x: 0, y: arrowHeight+radius))
            path.addArc(
                withCenter: CGPoint(x: radius, y: arrowHeight+radius),
                radius: radius,
                startAngle: .pi,
                endAngle: .pi/2*3,
                clockwise: true
            )
            path.close()
        } else {
            path.move(to: CGPoint(
                x: arrowPoint.x-arrowWidth,
                y: viewHeight-arrowHeight)
            )
            path.addLine(to: CGPoint(x: arrowPoint.x, y: viewHeight))
            path.addLine(to: CGPoint(
                x: arrowPoint.x+arrowWidth,
                y: viewHeight-arrowHeight)
            )
            path.addLine(to: CGPoint(
                x: viewWidth-radius,
                y: viewHeight-arrowHeight)
            )
            path.addArc(
                withCenter: CGPoint(
                    x: viewWidth-radius,
                    y: viewHeight-arrowHeight-radius),
                radius: radius,
                startAngle: .pi/2,
                endAngle: 0,
                clockwise: false
            )
            path.addLine(to: CGPoint(x: viewWidth, y: radius))
            path.addArc(
                withCenter: CGPoint(x: viewWidth - radius, y: radius),
                radius: radius,
                startAngle: 0,
                endAngle: .pi/2*3,
                clockwise: false
            )
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addArc(
                withCenter: CGPoint(x: radius, y: radius),
                radius: radius,
                startAngle: .pi/2*3,
                endAngle: .pi,
                clockwise: false
            )
            path.addLine(to: CGPoint(
                x: 0,
                y: viewHeight-arrowHeight-radius)
            )
            path.addArc(
                withCenter: CGPoint(
                    x: radius,
                    y: viewHeight-arrowHeight-radius),
                radius: radius,
                startAngle: .pi,
                endAngle: .pi/2,
                clockwise: false
            )
            path.close()
        }
        return path
    }
    
    func installAnchorPoint(_ view: UIView, point: CGPoint) -> CGPoint {
        var anchorPoint = CGPoint(x: point.x/view.frame.width, y: 0)
        if arrowDirection == .down {
            anchorPoint = CGPoint(x: point.x/view.frame.width, y: 1)
        }
        
        var newPoint = CGPoint(
            x: view.bounds.width*anchorPoint.x,
            y: view.bounds.height*anchorPoint.y
        )
        
        var oldPoint = CGPoint(
            x: view.bounds.width*view.layer.anchorPoint.x,
            y: view.bounds.height*view.layer.anchorPoint.y
        )
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        let offsetX = view.frame.minX
        let offsetY = view.frame.minY
        let newOffsetX = offsetX + view.frame.width * (anchorPoint.x-view.layer.anchorPoint.x)
        let newOffsetY = offsetY + view.frame.height * (anchorPoint.y-view.layer.anchorPoint.y)
        
        view.layer.anchorPoint = anchorPoint
        return CGPoint(x: newOffsetX, y: newOffsetY)
    }
}
