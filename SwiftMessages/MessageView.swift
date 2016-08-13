//
//  MessageView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

public class MessageView: DropShadowView, Identifiable, MarginAdjustable {

    /*
     MARK: - IB outlets
     */
    
    @IBOutlet public var titleLabel: UILabel?
    @IBOutlet public var bodyLabel: UILabel?
    @IBOutlet public var iconContainer: UIView?
    @IBOutlet public var iconImageView: UIImageView?
    @IBOutlet public var iconLabel: UILabel?
    @IBOutlet public var button: UIButton?
    @IBOutlet public var contentView: UIView?
    @IBOutlet public var backgroundView: UIView!
    
    /*
     MARK: - Creating message views
     */
    
    public enum Layout: String {
        case MessageView = "MessageView"
        case CardView = "CardView"
        case StatusLine = "StatusLine"
        case MessageViewIOS8 = "MessageViewIOS8"
    }

    public static func viewFromNib<T: MessageView>(layout layout: Layout) -> T {
        return try! UIView.viewFromNib(named: layout.rawValue)
    }

    public static func viewFromNib<T: MessageView>(layout layout: Layout, bundle: NSBundle) -> T {
        return try! UIView.viewFromNib(named: layout.rawValue, bundle: bundle)
    }

    /*
     MARK: - Configuring the theme
     */

    public func configureErrorTheme() {
        let backgroundColor = UIColor(red: 249.0/255.0, green: 66.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        let foregroundColor = UIColor.whiteColor()
        configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: Icon.Error.image)
    }

    public func configureWarningTheme() {
        let backgroundColor = UIColor(red: 238.0/255.0, green: 189.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        let foregroundColor = UIColor.whiteColor()
        configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: Icon.Warning.image)
    }

    public func configureInfoTheme() {
        let backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        let foregroundColor = UIColor.darkTextColor()
        configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: Icon.Info.image)
    }
    
    public func configureTheme(backgroundColor backgroundColor: UIColor, foregroundColor: UIColor, iconImage: UIImage) {
        iconImageView?.image = iconImage
        iconLabel?.text = nil
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
    }

    public override func configureDropShadow() {
        configureDropShadow(backgroundView ?? self)
    }
    
    /*
     MARK: - Configuring the content
     */

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
        iconLabel?.text = nil
    }

    public func configureContent(title title: String, body: String, iconText: String) {
        configureContent(title: title, body: body)
        iconImageView?.image = nil
        iconLabel?.text = iconText
    }

    public func configureContent(title title: String?, body: String?, iconImage: UIImage?, iconText: String?, buttonImage: UIImage?, buttonTitle: String?, buttonHandler: (() -> Void)?) {
        titleLabel?.text = title
        bodyLabel?.text = body
        iconImageView?.image = iconImage
        iconLabel?.text = iconText
        button?.setImage(buttonImage, forState: .Normal)
        button?.setTitle(buttonTitle, forState: .Normal)
        // TODO set button tap handler
    }    
    
    /*
     MARK: - Initialization
     */
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundView = self
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundView = self
    }
    
    public override func awakeFromNib() {
        layoutMargins = UIEdgeInsetsZero
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
