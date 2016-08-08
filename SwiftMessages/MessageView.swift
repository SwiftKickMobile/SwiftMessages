//
//  MessageView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

public class MessageView: UIView, Identifiable, MarginAdjustable {
    
    /*
     MARK: - IB outlets
     */
    
    @IBOutlet public var titleLabel: UILabel?
    @IBOutlet public var bodyLabel: UILabel?
    @IBOutlet public var iconImage: UIImageView?
    @IBOutlet public var iconLabel: UILabel?
    @IBOutlet public var button: UIButton?
    
    /*
     MARK: - Creating message views
     */
    
    public enum Layout: String {
        case MessageView = "MessageView"
        case StatusLine = "StatusLine"
    }
    
    public static func instantiate(layout layout: Layout) -> MessageView {
        return try! MessageView.viewFromNib(named: layout.rawValue)
    }
    
    /*
     MARK: - Configuring the theme
     */

    public func configureErrorTheme() {
        setIcon(Icon.Error)
        iconImage?.tintColor = UIColor.whiteColor()
        backgroundColor = UIColor(red: 249.0/255.0, green: 66.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        iconLabel?.textColor = UIColor.whiteColor()
        titleLabel?.textColor = UIColor.whiteColor()
        bodyLabel?.textColor = UIColor.whiteColor()
    }

    /*
     MARK: - Configuring the content
     */

    public func configureContent(body body: String) {
        configureContent(title: nil, body: body, icon: nil, buttonIcon: nil, buttonTitle: nil, buttonHandler: nil)
    }
    
    public func configureContent(title title: String, body: String) {
        configureContent(title: title, body: body, icon: nil, buttonIcon: nil, buttonTitle: nil, buttonHandler: nil)
    }
    
    public func configureContent(title title: String, body: String, icon: Icon) {
        configureContent(title: title, body: body, icon: icon, buttonIcon: nil, buttonTitle: nil, buttonHandler: nil)
    }
    
    public func configureContent(title title: String?, body: String?, icon: Icon?, buttonIcon: Icon?, buttonTitle: String?, buttonHandler: (() -> Void)?) {
        titleLabel?.text = title
        bodyLabel?.text = body
        if let icon = icon {
            setIcon(icon)
        }
        if let buttonIcon = buttonIcon {
            button?.setImage(buttonIcon.image, forState: .Normal)
        }
        if let buttonTitle = buttonTitle {
            button?.setTitle(buttonTitle, forState: .Normal)
        }
        // TODO set button tap handler
    }    
    
    func setIcon(icon: Icon?) {
        iconImage?.image = icon?.image
        iconLabel?.text = icon?.text
    }

    /*
     MARK: - Initialization
     */
    
    public override func awakeFromNib() {
        self.titleLabel?.text = nil
        self.bodyLabel?.text = nil
        self.iconImage?.image = nil
        self.iconLabel?.text = nil
        self.button?.setImage(nil, forState: .Normal)
        self.button?.setTitle(nil, forState: .Normal)
        self.layoutMargins = UIEdgeInsetsZero
    }
    
    /*
     MARK: - Identifiable
     */
    
    public var id: String {
        return "MessageView:title=\(titleLabel?.text), body=\(bodyLabel?.text)"
    }
    
    /*
     MARK: - MarginAdjustable
     */
    
    @IBInspectable public var bounceAnimationOffset: CGFloat = 5.0
    
    @IBInspectable public var statusBarOffset: CGFloat = 20.0
}
