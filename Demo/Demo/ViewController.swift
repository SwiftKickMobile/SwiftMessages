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
        .TitleBody(title: "MESSAGE VIEW", body: "SwiftMessages provides a standard message view along with a number of layouts, themes and presentation options.", function: ViewController.demoBasics),
        .TitleBody(title: "ANY VIEW", body: "Any view, no matter how cute, can be displayed as a message.", function: ViewController.demoAnyView),
        .TitleBody(title: "CUSTOMIZE", body: "Easily customize by copying one of the SwiftMessages nib files into your project as a starting point. Then order some tacos.", function: ViewController.demoCustomNib),
        .Explore,
    ]

    /*
     MARK: - UITableViewDataSource
     */
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        return item.dequeueCell(tableView: tableView)
    }
    
    /*
     MARK: - UITableViewDelegate
     */

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = items[indexPath.row]
        item.performDemo()
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /*
     MARK: - Demos
     */

    static func demoBasics() -> Void {

        let error = MessageView.viewFromNib(layout: .MessageView)
        error.configureErrorTheme()
        error.configureContent(title: "Error", body: "Something is horribly wrong!")
        error.button?.setTitle("Stop", forState: .Normal)
        error.iconContainer?.hidden = true
        
        let warning = MessageView.viewFromNib(layout: .CardView)
        warning.configureWarningTheme()
        warning.configureDropShadow()
        warning.configureContent(title: "Warning", body: "Consider yourself warned.", iconText: "🤔")
        warning.button?.hidden = true
        var warningConfig = SwiftMessages.Config()
        warningConfig.presentationContext = .Window(windowLevel: UIWindowLevelStatusBar)
        
        let info = MessageView.viewFromNib(layout: .MessageView)
        info.configureInfoTheme()
        info.button?.hidden = true
        info.configureContent(title: "Info", body: "This is a very lengthy and informative info message that wraps across multiple lines and grows in height as needed.")
        var infoConfig = SwiftMessages.Config()
        infoConfig.presentationStyle = .Bottom

        let status = MessageView.viewFromNib(layout: .StatusLine)
        status.backgroundView.backgroundColor = UIColor.purpleColor()
        status.bodyLabel?.textColor = UIColor.whiteColor()
        status.configureContent(body: "A tiny line of text covering the status bar.")
        var statusConfig = SwiftMessages.Config()
        statusConfig.presentationContext = .Window(windowLevel: UIWindowLevelStatusBar)

        let status2 = MessageView.viewFromNib(layout: .StatusLine)
        status2.backgroundView.backgroundColor = UIColor.orangeColor()
        status2.bodyLabel?.textColor = UIColor.whiteColor()
        status2.configureContent(body: "Switched to light status bar!")
        var status2Config = SwiftMessages.Config()
        status2Config.presentationContext = .Window(windowLevel: UIWindowLevelNormal)
        status2Config.preferredStatusBarStyle = .LightContent

        SwiftMessages.show(view: error)
        SwiftMessages.show(config: warningConfig, view: warning)
        SwiftMessages.show(config: infoConfig, view: info)
        SwiftMessages.show(config: statusConfig, view: status)
        SwiftMessages.show(config: status2Config, view: status2)
    }
    
    static func demoAnyView() -> Void {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "puppies")
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        let shadowView = DropShadowView()
        shadowView.installView(imageView)
        shadowView.configureDropShadow()
        shadowView.constrainHeight(120.0)
        shadowView.backgroundColor = UIColor.redColor()
        var config = SwiftMessages.Config()
        config.presentationContext = .Window(windowLevel: UIWindowLevelStatusBar)
        SwiftMessages.show(config: config, view: shadowView)
    }

    static func demoCustomNib() {
        let view: TacoDialogView = try! TacoDialogView.viewFromNib()
        view.configureDropShadow()
        view.getTacosAction = { _ in SwiftMessages.hide() }
        view.cancelAction = { SwiftMessages.hide() }
        var config = SwiftMessages.Config()
        config.presentationContext = .Window(windowLevel: UIWindowLevelStatusBar)
        config.duration = .Forever
        config.presentationStyle = .Bottom
        config.dimMode = .Automatic(interactive: true)
        SwiftMessages.show(config: config, view: view)
    }

    static func demoExplore() {
        
    }
}

typealias Function = () -> Void

enum Item {
    
    case TitleBody(title: String, body: String, function: Function)
    case Explore
    
    func dequeueCell(tableView tableView: UITableView) -> UITableViewCell {
        switch self {
        case .TitleBody(let data):
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleBody") as! TitleBodyCell
            cell.titleLabel.text = data.title
            cell.bodyLabel.text = data.body
            cell.configureBodyTextStyle()
            return cell
        case .Explore:
            let cell = tableView.dequeueReusableCellWithIdentifier("Explore") as! TitleBodyCell
            cell.configureBodyTextStyle()
            return cell
        }
    }
    
    func performDemo() {
        switch self {
        case .TitleBody(let data):
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

