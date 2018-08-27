//
//  MessagesViewController.swift
//  iMessageDemo
//
//  Created by Timothy Moose on 5/25/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit
import Messages
import SwiftMessages

class MessagesViewController: MSMessagesAppViewController {

    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.cornerRadius = 5
        }
    }

    @IBAction func buttonTapped() {
        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
        messageView.configureContent(title: "Test", body: "Yep, it works!")
        messageView.button?.isHidden = true
        messageView.iconLabel?.isHidden = true
        messageView.iconImageView?.isHidden = true
        messageView.configureTheme(backgroundColor: .black, foregroundColor: .white)
        messageView.configureDropShadow()
        messageView.configureBackgroundView(width: 200)
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.presentationContext = .viewController(self)
        SwiftMessages.show(config: config, view: messageView)
    }
}
