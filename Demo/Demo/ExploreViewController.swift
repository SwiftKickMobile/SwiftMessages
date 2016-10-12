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

    @IBAction func show(_ sender: AnyObject) {
        
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
            iconStyle = .light
        case 2:
            iconStyle = .subtle
        default:
            iconStyle = .default
        }
        
        switch theme.selectedSegmentIndex {
        case 0:
            view.configureTheme(.info, iconStyle: iconStyle)
        case 1:
            view.configureTheme(.success, iconStyle: iconStyle)
        case 2:
            view.configureTheme(.warning, iconStyle: iconStyle)
        case 3:
            view.configureTheme(.error, iconStyle: iconStyle)
        default:
            let iconText = ["🐸", "🐷", "🐬", "🐠", "🐍", "🐹", "🐼"].sm_random()
            view.configureTheme(backgroundColor: UIColor.purple, foregroundColor: UIColor.white, iconImage: nil, iconText: iconText)
            view.button?.setImage(Icon.ErrorSubtle.image, for: .normal)
            view.button?.setTitle(nil, for: .normal)
            view.button?.backgroundColor = UIColor.clear
            view.button?.tintColor = UIColor.green.withAlphaComponent(0.7)
        }
        
        if dropShadow.isOn {
            view.configureDropShadow()
        }
        
        if !showButton.isOn {
            view.button?.isHidden = true
        }
        
        if !showIcon.isOn {
            view.iconImageView?.isHidden = true
            view.iconLabel?.isHidden = true
        }
        
        if !showTitle.isOn {
            view.titleLabel?.isHidden = true
        }
        
        if !showBody.isOn {
            view.bodyLabel?.isHidden = true
        }
        
        // Config setup
        
        var config = SwiftMessages.Config()
        
        switch presentationStyle.selectedSegmentIndex {
        case 1:
            config.presentationStyle = .bottom
        default:
            break
        }
        
        switch presentationContext.selectedSegmentIndex {
        case 1:
            config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        case 2:
            config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        default:
            break
        }
        
        switch duration.selectedSegmentIndex {
        case 1:
            config.duration = .forever
        case 2:
            config.duration = .seconds(seconds: 1)
        case 3:
            config.duration = .seconds(seconds: 5)
        default:
            break
        }
        
        switch dimMode.selectedSegmentIndex {
        case 1:
            config.dimMode = .gray(interactive: false)
        case 2:
            config.dimMode = .gray(interactive: true)
        default:
            break
        }

        config.shouldAutorotate = self.autoRotate.isOn
        
        config.interactiveHide = interactiveHide.isOn
        
        // Set status bar style unless using card view (since it doesn't
        // go behind the status bar).
        if case .top = config.presentationStyle, layout.selectedSegmentIndex != 1 {
            switch theme.selectedSegmentIndex {
            case 1...4:
                config.preferredStatusBarStyle = .lightContent
            default:
                break
            }
        }
        
        // Show
        SwiftMessages.show(config: config, view: view)
    }
    
    @IBAction func hide(_ sender: AnyObject) {
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
    @IBOutlet weak var autoRotate: UISwitch!
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
