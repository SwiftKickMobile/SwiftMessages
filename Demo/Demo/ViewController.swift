//
//  ViewController.swift
//  Demo
//
//  Created by Tim Moose on 8/11/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit
import SwiftMessages

class ViewController: UITableViewController {

    var items: [Item] = [
        .titleBody(title: "MESSAGE VIEW", body: "SwiftMessages provides a standard message view along with a number of layouts, themes and presentation options.", function: ViewController.demoBasics),
        .titleBody(title: "ANY VIEW", body: "Any view, no matter how cute, can be displayed as a message.", function: ViewController.demoAnyView),
        .titleBody(title: "CUSTOMIZE", body: "Easily customize by copying one of the SwiftMessages nib files into your project as a starting point. Then order some tacos.", function: ViewController.demoCustomNib),
        .explore,
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
        return UITableViewAutomaticDimension
    }
    
    /*
     MARK: - Demos
     */

    static func demoBasics() -> Void {

        let error = MessageView.viewFromNib(layout: .TabView)
        error.configureTheme(.error)
        error.configureContent(title: "Error", body: "Something is horribly wrong!")
        error.button?.setTitle("Stop", for: .normal)
        
        let warning = MessageView.viewFromNib(layout: .CardView)
        warning.configureTheme(.warning)
        warning.configureDropShadow()
        
        let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
        warning.configureContent(title: "Warning", body: "Consider yourself warned.", iconText: iconText)
        warning.button?.isHidden = true
        var warningConfig = SwiftMessages.Config()
        warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)

        let success = MessageView.viewFromNib(layout: .CardView)
        success.configureTheme(.success)
        success.configureDropShadow()
        success.configureContent(title: "Success", body: "Something good happened!")
        success.button?.isHidden = true
        var successConfig = SwiftMessages.Config()
        successConfig.presentationStyle = .bottom
        successConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)

        let info = MessageView.viewFromNib(layout: .MessageView)
        info.configureTheme(.info)
        info.button?.isHidden = true
        info.configureContent(title: "Info", body: "This is a very lengthy and informative info message that wraps across multiple lines and grows in height as needed.")
        var infoConfig = SwiftMessages.Config()
        infoConfig.presentationStyle = .bottom
        infoConfig.duration = .seconds(seconds: 0.25)

        let status = MessageView.viewFromNib(layout: .StatusLine)
        status.backgroundView.backgroundColor = UIColor.purple
        status.bodyLabel?.textColor = UIColor.white
        status.configureContent(body: "A tiny line of text covering the status bar.")
        var statusConfig = SwiftMessages.Config()
        statusConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)

        let status2 = MessageView.viewFromNib(layout: .StatusLine)
        status2.backgroundView.backgroundColor = UIColor.orange
        status2.bodyLabel?.textColor = UIColor.white
        status2.configureContent(body: "Switched to light status bar!")
        var status2Config = SwiftMessages.Config()
        status2Config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        status2Config.preferredStatusBarStyle = .lightContent

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
        let f = CGRect(x: 100, y: 100, width: 100, height: 100)
        let messageView = BaseView(frame: f)
        messageView.installContentView(imageView)
        messageView.preferredHeight = 120.0
        messageView.configureDropShadow()
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        SwiftMessages.show(config: config, view: messageView)
    }

    static func demoCustomNib() {
        let view: TacoDialogView = try! SwiftMessages.viewFromNib()
        view.configureDropShadow()
        view.getTacosAction = { _ in SwiftMessages.hide() }
        view.cancelAction = { SwiftMessages.hide() }
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: true)
        SwiftMessages.show(config: config, view: view)
    }

    static func demoExplore() {
        
    }
}

typealias Function = () -> Void

enum Item {
    
    case titleBody(title: String, body: String, function: Function)
    case explore
    
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
        bodyLabel.attributedText = NSAttributedString(string: bodyLabel.text ?? "", attributes: [NSParagraphStyleAttributeName : bodyStyle])
    }
}

