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
        .TitleBody(title: "ANY VIEW", body: "Any arbitrary view can be displayed as a message bar.", function: ViewController.demoAnyView),
        .TitleBody(title: "CUSTOMIZE NIBS", body: "blah blah blah.", function: ViewController.demoAnyView),
        .TitleBody(title: "BLAH", body: "blah blah blah.", function: ViewController.demoAnyView),
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
        error.configureContent(title: "Error", body: "Something is horribly wrong!.")
        error.button?.setTitle("STOP!", forState: .Normal)

        let warning = MessageView.viewFromNib(layout: .CardView)
        warning.configureWarningTheme()
        warning.configureDropShadow()
        warning.configureContent(title: "Warning", body: "Consider yourself warned.", iconText: "🤔")
        warning.button?.hidden = true
        var warningConfig = Configuration()
        warningConfig.presentationContext = .Window(windowLevel: UIWindowLevelStatusBar)
        
        let info = MessageView.viewFromNib(layout: .MessageView)
        info.configureInfoTheme()
        info.button?.hidden = true
        info.configureContent(title: "Info", body: "This is a very lengthy and informative info message that wraps across multiple lines.")
        var infoConfig = Configuration()
        infoConfig.presentationStyle = .Bottom

        let info2 = MessageView.viewFromNib(layout: .StatusLine)
        info2.backgroundView.backgroundColor = UIColor.purpleColor()
        info2.bodyLabel?.textColor = UIColor.whiteColor()
        info2.configureContent(body: "A tiny line of text covering the status bar.")
        var info2Config = Configuration()
        info2Config.presentationContext = .Window(windowLevel: UIWindowLevelStatusBar)
        
        SwiftMessages.show(view: error)
        SwiftMessages.show(configuration: warningConfig, view: warning)
        SwiftMessages.show(configuration: infoConfig, view: info)
        SwiftMessages.show(configuration: info2Config, view: info2)
    }
    
    static func demoAnyView() -> Void {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "puppies")
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(120)]", options: [], metrics: nil, views: ["imageView" : imageView]))
        SwiftMessages.show(view: imageView)
    }

    static func demo2() {
        
    }

    static func demo3() {
        
    }
}

typealias Function = () -> Void

enum Item {
    
    case TitleBody(title: String, body: String, function: Function)
    
    func dequeueCell(tableView tableView: UITableView) -> UITableViewCell {
        switch self {
        case .TitleBody(let data):
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleBody") as! TitleBodyCell
            cell.titleLabel.text = data.title
            let bodyStyle = NSMutableParagraphStyle()
            bodyStyle.lineSpacing = 5.0
            cell.bodyLabel.attributedText = NSAttributedString(string: data.body, attributes: [NSParagraphStyleAttributeName : bodyStyle])
            return cell
        }
    }
    
    func performDemo() {
        switch self {
        case .TitleBody(let data):
            data.function()
        }
    }
}

class TitleBodyCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
}

