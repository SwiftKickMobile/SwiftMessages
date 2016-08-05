//
//  GalleryTableViewController.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 7/30/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import UIKit

class GalleryTableViewController: UITableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let style = MessageView.errorConfiguration()
        let content = MessageView.contentConfiguration(title: "My Title", body: "This is my body message.")
        var config = Configuration<MessageView>(viewConfigurations: [style, content])
//        config.presentationContext = .Window(windowLevel: UIWindowLevelStatusBar)
        config.presentationContext = .Automatic
        config.presentationStyle = .Top
        try! config.show()
    }
}

