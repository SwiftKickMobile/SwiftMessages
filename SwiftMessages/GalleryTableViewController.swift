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
        config.presentationContext = .OverWindow(windowLevel: UIWindowLevelStatusBar)
        try! config.show()
        let content2 = MessageView.contentConfiguration(title: "My Title 2", body: "This is my body message 2.")
        var config2 = Configuration<MessageView>(viewConfigurations: [style, content2])
        config2.presentationContext = .OverWindow(windowLevel: UIWindowLevelStatusBar)
        try! config2.show()
        let content3 = MessageView.contentConfiguration(title: "My Title", body: "This is my body message.")
        var config3 = Configuration<MessageView>(viewConfigurations: [style, content3])
        config3.presentationContext = .OverWindow(windowLevel: UIWindowLevelStatusBar)
        try! config3.show()
    }
}

