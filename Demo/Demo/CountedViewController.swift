//
//  CountedViewController.swift
//  Demo
//
//  Created by Timothy Moose on 8/25/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit
#if os(iOS)
import SwiftMessages
#else
import SwiftMessagesTvOS
#endif

class CountedViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var messageView: CountedMessageView!
    @IBOutlet weak var messageContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.configureBodyTextStyle()
        descriptionLabel.configureCodeStyle(on: "show()")
        descriptionLabel.configureCodeStyle(on: "hideCounted(id:)")
    }

    @IBAction func show() {
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.duration = .forever
        config.presentationContext = .view(messageContainer)
        SwiftMessages.show(config: config, view: messageView)
        updateCountLabel()
    }

    @IBAction func hide() {
        SwiftMessages.hideCounted(id: messageView.id)
        updateCountLabel()
    }

    private func updateCountLabel() {
        let count = SwiftMessages.count(id: messageView.id)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .spellOut
        messageView.countLabel.text = numberFormatter.string(from: NSNumber(value: count))?.uppercased()
    }
}
