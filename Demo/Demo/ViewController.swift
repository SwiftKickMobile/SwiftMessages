//
//  ViewController.swift
//  Demo
//
//  Created by Tim Moose on 8/11/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit
#if os(iOS)
import SwiftMessages
#else
import SwiftMessagesTvOS
#endif

class ViewController: UITableViewController {

    var items: [Item] = [
        .titleBody(title: "MESSAGE VIEW", body: "SwiftMessages provides a standard message view along with a number of layouts, themes and presentation options.", function: ViewController.demoBasics),
        .titleBody(title: "ANY VIEW", body: "Any view, no matter how cute, can be displayed as a message.", function: ViewController.demoAnyView),
        .titleBody(title: "CUSTOMIZE", body: "Easily customize by copying one of the SwiftMessages nib files into your project as a starting point. Then order some tacos.", function: ViewController.demoCustomNib),
        .explore,
        .titleBody(title: "CENTERED", body: "Show cenetered messages with a fun, physics-based dismissal gesture.", function: ViewController.demoCentered),
        .viewController,
        //.counted,
    ]

    /*
     MARK: - UITableViewDataSource
     */
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[(indexPath as NSIndexPath).row]
        return item.dequeueCell(tableView)
    }
    
    /*
     MARK: - UITableViewDelegate
     */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[(indexPath as NSIndexPath).row]
        item.performDemo()
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /*
     MARK: - Demos
     */

    static func demoBasics() -> Void {
        
        let error = MessageView.viewFromNib(layout: .tabView)
        error.configureTheme(.error)
        error.configureContent(title: "Error", body: "Something is horribly wrong!")
        error.button?.setTitle("Stop", for: .normal)
        
        let warning = MessageView.viewFromNib(layout: .cardView)
        warning.configureTheme(.warning)
        warning.configureDropShadow()
        
        let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
        warning.configureContent(title: "Warning", body: "Consider yourself warned.", iconText: iconText)
        warning.button?.isHidden = true
        var warningConfig = SwiftMessages.defaultConfig
        #if os(iOS)
        warningConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        #else
        warningConfig.presentationContext = .window(windowLevel: UIWindow.Level.alert)
        #endif

        let success = MessageView.viewFromNib(layout: .cardView)
        success.configureTheme(.success)
        success.configureDropShadow()
        success.configureContent(title: "Success", body: "Something good happened!")
        success.button?.isHidden = true
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = .center
        successConfig.presentationContext = .window(windowLevel: UIWindow.Level.normal)

        let info = MessageView.viewFromNib(layout: .messageView)
        info.configureTheme(.info)
        info.button?.isHidden = true
        info.configureContent(title: "Info", body: "This is a very lengthy and informative info message that wraps across multiple lines and grows in height as needed.")
        var infoConfig = SwiftMessages.defaultConfig
        infoConfig.presentationStyle = .bottom
        infoConfig.duration = .seconds(seconds: 0.25)

        let status = MessageView.viewFromNib(layout: .statusLine)
        status.backgroundView.backgroundColor = UIColor.purple
        status.bodyLabel?.textColor = UIColor.white
        status.configureContent(body: "A tiny line of text covering the status bar.")
        var statusConfig = SwiftMessages.defaultConfig
        #if os(iOS)
        statusConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        #else
        statusConfig.presentationContext = .window(windowLevel: UIWindow.Level.alert)
        #endif

        let status2 = MessageView.viewFromNib(layout: .statusLine)
        status2.backgroundView.backgroundColor = UIColor.orange
        status2.bodyLabel?.textColor = UIColor.white
        status2.configureContent(body: "Switched to light status bar!")
        var status2Config = SwiftMessages.defaultConfig
        status2Config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        #if os(iOS)
        status2Config.preferredStatusBarStyle = .lightContent
        #endif

        SwiftMessages.show(view: error)
        SwiftMessages.show(config: warningConfig, view: warning)
        SwiftMessages.show(config: successConfig, view: success)
        SwiftMessages.show(config: infoConfig, view: info)
        SwiftMessages.show(config: statusConfig, view: status)
        SwiftMessages.show(config: status2Config, view: status2)
    }
    
    static func demoAnyView() -> Void {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "puppies")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        let messageView = BaseView(frame: .zero)
        messageView.layoutMargins = .zero
        messageView.backgroundHeight = 120.0
        do {
            let backgroundView = CornerRoundingView()
            backgroundView.cornerRadius = 15
            backgroundView.layer.masksToBounds = true
            messageView.installBackgroundView(backgroundView)
            messageView.installContentView(imageView)
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        messageView.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        #if os(iOS)
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        #else
        config.presentationContext = .window(windowLevel: UIWindow.Level.alert)
        #endif
        SwiftMessages.show(config: config, view: messageView)
    }

    static func demoCustomNib() {
        let view: TacoDialogView = try! SwiftMessages.viewFromNib()
        view.configureDropShadow()
        view.getTacosAction = { _ in SwiftMessages.hide() }
        view.cancelAction = { SwiftMessages.hide() }
        var config = SwiftMessages.defaultConfig
        #if os(iOS)
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        #else
        config.presentationContext = .window(windowLevel: UIWindow.Level.alert)
        #endif
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: true)
        SwiftMessages.show(config: config, view: view)
    }

    static func demoCentered() {
        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
        messageView.configureBackgroundView(width: 250)
        messageView.configureContent(title: "Hey There!", body: "Please try swiping to dismiss this message.", iconImage: nil, iconText: "🦄", buttonImage: nil, buttonTitle: "No Thanks") { _ in
            SwiftMessages.hide()
        }
        messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
        messageView.backgroundView.layer.cornerRadius = 10
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.duration = .forever
        config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
        #if os(iOS)
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        #else
        config.presentationContext = .window(windowLevel: UIWindow.Level.alert)
        #endif
        SwiftMessages.show(config: config, view: messageView)
    }
}

typealias Function = () -> Void

enum Item {
    
    case titleBody(title: String, body: String, function: Function)
    case explore
    case counted
    case viewController

    func dequeueCell(_ tableView: UITableView) -> UITableViewCell {
        switch self {
        case .titleBody(let data):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleBody") as! TitleBodyCell
            cell.titleLabel.text = data.title
            cell.bodyLabel.text = data.body
            cell.configureBodyTextStyle()
            return cell
        case .explore:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Explore") as! TitleBodyCell
            cell.configureBodyTextStyle()
            return cell
        case .counted:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Counted") as! TitleBodyCell
            cell.configureBodyTextStyle()
            cell.bodyLabel.configureCodeStyle(on: "show()")
            cell.bodyLabel.configureCodeStyle(on: "hideCounted(id:)")
            return cell
        case .viewController:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ViewController") as! TitleBodyCell
            cell.configureBodyTextStyle()
            return cell
        }
    }
    
    func performDemo() {
        switch self {
        case .titleBody(let data):
            data.function()
        default:
            break
        }
    }
}

class TitleBodyCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    
    func configureBodyTextStyle() {
        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.lineSpacing = 5.0
        bodyLabel.configureBodyTextStyle()
    }
}
