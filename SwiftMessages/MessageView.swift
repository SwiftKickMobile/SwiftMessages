//
//  MessageView.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

public class MessageView: UIView {
    
    /*
     MARK: - IB outlets
     */
    
    @IBOutlet public var titleLabel: UILabel?
    @IBOutlet public var bodyLabel: UILabel?
    @IBOutlet public var iconImage: UIImageView?
    @IBOutlet public var iconLabel: UILabel?
    @IBOutlet public var button: UIButton?

    /*
     MARK: - Style configurations
     */

    public static func errorConfiguration() -> Configuration<MessageView>.ViewConfiguration {
        return { view in
            view.iconImage?.image = Icon.Error.image
            view.iconImage?.tintColor = UIColor.whiteColor()
            view.backgroundColor = UIColor(red: 249.0/255.0, green: 66.0/255.0, blue: 47.0/255.0, alpha: 1.0)
            view.iconLabel?.textColor = UIColor.whiteColor()
            view.titleLabel?.textColor = UIColor.whiteColor()
            view.bodyLabel?.textColor = UIColor.whiteColor()
            // TODO button style
        }
    }

    /*
     MARK: - Content configurations
     */
    
    public static func contentConfiguration(body body: String) -> Configuration<MessageView>.ViewConfiguration {
        return contentConfiguration(title: nil, body: body, icon: nil, buttonIcon: nil, buttonTitle: nil, buttonHandler: nil)
    }

    public static func contentConfiguration(title title: String, body: String) -> Configuration<MessageView>.ViewConfiguration {
        return contentConfiguration(title: title, body: body, icon: nil, buttonIcon: nil, buttonTitle: nil, buttonHandler: nil)
    }

    public static func contentConfiguration(title title: String, body: String, icon: Icon) -> Configuration<MessageView>.ViewConfiguration {
        return contentConfiguration(title: title, body: body, icon: icon, buttonIcon: nil, buttonTitle: nil, buttonHandler: nil)
    }

    public static func contentConfiguration(title title: String?, body: String?, icon: Icon?, buttonIcon: Icon?, buttonTitle: String?, buttonHandler: (() -> Void)?) -> Configuration<MessageView>.ViewConfiguration {
        return { view in
            view.titleLabel?.text = title
            view.bodyLabel?.text = body
            if let image = icon?.image, let iconImage = view.iconImage {
                iconImage.image = image
                view.iconLabel?.text = nil
            }
            if let text = icon?.text, let iconLabel = view.iconLabel {
                iconLabel.text = text
                view.iconImage?.image = nil
            }
            if let buttonIcon = buttonIcon {
                view.button?.setImage(buttonIcon.image, forState: .Normal)
            }
            if let buttonTitle = buttonTitle {
                view.button?.setTitle(buttonTitle, forState: .Normal)
            }
            // TODO set button tap handler
        }
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
    }
}
