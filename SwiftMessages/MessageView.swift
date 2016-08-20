//
//  MessageView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

public class MessageView: BaseView, Identifiable {
    
    /*
     MARK: - Creating message views
     */
    
    /**
     
    */
    public enum Layout: String {
        case MessageView = "MessageView"
        case CardView = "CardView"
        case StatusLine = "StatusLine"
        case MessageViewIOS8 = "MessageViewIOS8"
    }
    
    public static func viewFromNib<T: MessageView>(layout layout: Layout, filesOwner: AnyObject = NSNull.init()) -> T {
        return try! SwiftMessages.viewFromNib(named: layout.rawValue)
    }
    
    public static func viewFromNib<T: MessageView>(layout layout: Layout, bundle: NSBundle, filesOwner: AnyObject = NSNull.init()) -> T {
        return try! SwiftMessages.viewFromNib(named: layout.rawValue, bundle: bundle, filesOwner: filesOwner)
    }
    
    /*
     MARK: - Button tap handler
     */
    
    public var buttonTapHandler: ((button: UIButton) -> Void)?
    
    func buttonTapped(button: UIButton) {
        buttonTapHandler?(button: button)
    }
    
    /*
     MARK: - IB outlets
     */
    
    @IBOutlet public var titleLabel: UILabel?
    @IBOutlet public var bodyLabel: UILabel?
    @IBOutlet public var iconImageView: UIImageView?
    @IBOutlet public var iconLabel: UILabel?
    
    @IBOutlet public var button: UIButton? {
        didSet {
            if let old = oldValue {
                old.removeTarget(self, action: #selector(MessageView.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            }
            if let button = button {
                button.addTarget(self, action: #selector(MessageView.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            }
        }
    }
    
    /*
     MARK: - Identifiable
     */
    
    public var id: String {
        return "MessageView:title=\(titleLabel?.text), body=\(bodyLabel?.text)"
    }
}

/*
 MARK: - Theming
 */

extension MessageView {
    
    public func configureTheme(theme: Theme, iconStyle: IconStyle = .Default) {
        let iconImage = iconStyle.image(theme: theme)
        switch theme {
        case .Info:
            let backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            let foregroundColor = UIColor.darkTextColor()
            configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: iconImage)
        case .Success:
            let backgroundColor = UIColor(red: 97.0/255.0, green: 161.0/255.0, blue: 23.0/255.0, alpha: 1.0)
            let foregroundColor = UIColor.whiteColor()
            configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: iconImage)
        case .Warning:
            let backgroundColor = UIColor(red: 238.0/255.0, green: 189.0/255.0, blue: 34.0/255.0, alpha: 1.0)
            let foregroundColor = UIColor.whiteColor()
            configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: iconImage)
        case .Error:
            let backgroundColor = UIColor(red: 249.0/255.0, green: 66.0/255.0, blue: 47.0/255.0, alpha: 1.0)
            let foregroundColor = UIColor.whiteColor()
            configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: iconImage)
        }
    }
    
    public func configureTheme(backgroundColor backgroundColor: UIColor, foregroundColor: UIColor, iconImage: UIImage? = nil, iconText: String? = nil) {
        iconImageView?.image = iconImage
        iconLabel?.text = iconText
        iconImageView?.tintColor = foregroundColor
        let backgroundView = self.backgroundView ?? self
        backgroundView.backgroundColor = backgroundColor
        iconLabel?.textColor = foregroundColor
        titleLabel?.textColor = foregroundColor
        bodyLabel?.textColor = foregroundColor
        button?.backgroundColor = foregroundColor
        button?.tintColor = backgroundColor
        button?.contentEdgeInsets = UIEdgeInsetsMake(7.0, 7.0, 7.0, 7.0)
        button?.layer.cornerRadius = 5.0
        iconImageView?.hidden = iconImageView?.image == nil
        iconLabel?.hidden = iconLabel?.text == nil
    }
}

/*
 MARK: - Configuring the content
 */

extension MessageView {
    
    public func configureContent(body body: String) {
        bodyLabel?.text = body
    }
    
    public func configureContent(title title: String, body: String) {
        configureContent(body: body)
        titleLabel?.text = title
    }
    
    public func configureContent(title title: String, body: String, iconImage: UIImage) {
        configureContent(title: title, body: body)
        iconImageView?.image = iconImage
        iconImageView?.hidden = false
        iconLabel?.text = nil
        iconLabel?.hidden = true
    }
    
    public func configureContent(title title: String, body: String, iconText: String) {
        configureContent(title: title, body: body)
        iconLabel?.text = iconText
        iconLabel?.hidden = false
        iconImageView?.hidden = true
        iconImageView?.image = nil
    }
    
    public func configureContent(title title: String?, body: String?, iconImage: UIImage?, iconText: String?, buttonImage: UIImage?, buttonTitle: String?, buttonTapHandler: ((button: UIButton) -> Void)?) {
        titleLabel?.text = title
        bodyLabel?.text = body
        iconImageView?.image = iconImage
        iconLabel?.text = iconText
        button?.setImage(buttonImage, forState: .Normal)
        button?.setTitle(buttonTitle, forState: .Normal)
        self.buttonTapHandler = buttonTapHandler
    }
}
