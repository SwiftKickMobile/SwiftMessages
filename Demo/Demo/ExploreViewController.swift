//
//  ExploreViewController.swift
//  Demo
//
//  Created by Tim Moose on 8/13/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit
import SwiftMessages

class ExploreViewController: UITableViewController, UITextFieldDelegate {

    @IBAction func show(sender: AnyObject) {
        
        // View setup
        
        let view: MessageView
        switch layout.selectedSegmentIndex {
        case 1:
            view = MessageView.viewFromNib(layout: .CardView)
        case 2:
            view = MessageView.viewFromNib(layout: .TabView)
        case 3:
            view = MessageView.viewFromNib(layout: .StatusLine)
        default:
            view = try! SwiftMessages.viewFromNib()
        }
        
        view.configureContent(title: titleText.text, body: bodyText.text, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "Hide", buttonTapHandler: { _ in SwiftMessages.hide() })

        let iconStyle: IconStyle
        switch self.iconStyle.selectedSegmentIndex {
        case 1:
            iconStyle = .Light
        case 2:
            iconStyle = .Subtle
        default:
            iconStyle = .Default
        }
        
        switch theme.selectedSegmentIndex {
        case 0:
            view.configureTheme(.Info, iconStyle: iconStyle)
        case 1:
            view.configureTheme(.Success, iconStyle: iconStyle)
        case 2:
            view.configureTheme(.Warning, iconStyle: iconStyle)
        case 3:
            view.configureTheme(.Error, iconStyle: iconStyle)
        default:
            let iconText = ["🐸", "🐷", "🐬", "🐠", "🐍", "🐹", "🐼"].sm_random()
            view.configureTheme(backgroundColor: UIColor.purpleColor(), foregroundColor: UIColor.whiteColor(), iconImage: nil, iconText: iconText)
            view.button?.setImage(Icon.ErrorSubtle.image, forState: .Normal)
            view.button?.setTitle(nil, forState: .Normal)
            view.button?.backgroundColor = UIColor.clearColor()
            view.button?.tintColor = UIColor.greenColor().colorWithAlphaComponent(0.7)
        }
        
        if dropShadow.on {
            view.configureDropShadow()
        }
        
        if !showButton.on {
            view.button?.hidden = true
        }
        
        if !showIcon.on {
            view.iconImageView?.hidden = true
            view.iconLabel?.hidden = true
        }
        
        if !showTitle.on {
            view.titleLabel?.hidden = true
        }
        
        if !showBody.on {
            view.bodyLabel?.hidden = true
        }
        
        // Config setup
        
        var config = SwiftMessages.Config()
        
        switch presentationStyle.selectedSegmentIndex {
        case 1:
            config.presentationStyle = .Bottom
        default:
            break
        }
        
        switch presentationContext.selectedSegmentIndex {
        case 1:
            config.presentationContext = .Window(windowLevel: UIWindowLevelNormal)
        case 2:
            config.presentationContext = .Window(windowLevel: UIWindowLevelStatusBar)
        default:
            break
        }
        
        switch duration.selectedSegmentIndex {
        case 1:
            config.duration = .Forever
        case 2:
            config.duration = .Seconds(seconds: 1)
        case 3:
            config.duration = .Seconds(seconds: 5)
        default:
            break
        }
        
        switch dimMode.selectedSegmentIndex {
        case 1:
            config.dimMode = .Gray(interactive: false)
        case 2:
            config.dimMode = .Gray(interactive: true)
        default:
            break
        }
        
        config.interactiveHide = interactiveHide.on
        
        // Set status bar style unless using card view (since it doesn't
        // go behind the status bar).
        if case .Top = config.presentationStyle where layout.selectedSegmentIndex != 1 {
            switch theme.selectedSegmentIndex {
            case 1...4:
                config.preferredStatusBarStyle = .LightContent
            default:
                break
            }
        }
        
        // Show
        SwiftMessages.show(config: config, view: view)
    }
    
    @IBAction func hide(sender: AnyObject) {
        SwiftMessages.hide()
    }

    @IBOutlet weak var presentationStyle: UISegmentedControl!
    @IBOutlet weak var presentationContext: UISegmentedControl!
    @IBOutlet weak var duration: UISegmentedControl!
    @IBOutlet weak var dimMode: UISegmentedControl!
    @IBOutlet weak var interactiveHide: UISwitch!
    @IBOutlet weak var layout: UISegmentedControl!
    @IBOutlet weak var theme: UISegmentedControl!
    @IBOutlet weak var iconStyle: UISegmentedControl!
    @IBOutlet weak var dropShadow: UISwitch!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var bodyText: UITextField!
    @IBOutlet weak var showButton: UISwitch!
    @IBOutlet weak var showIcon: UISwitch!
    @IBOutlet weak var showTitle: UISwitch!
    @IBOutlet weak var showBody: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleText.delegate = self
        bodyText.delegate = self
    }
    
    /*
     MARK: - UITextFieldDelegate
     */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
}
