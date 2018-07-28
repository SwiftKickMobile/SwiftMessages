//
//  ViewControllersViewController.swift
//  Demo
//
//  Created by Timothy Moose on 7/28/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit
import SwiftMessages

class ViewControllersViewController: UIViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segue = segue as? SwiftMessagesSegue {
            segue.messageView.backgroundHeight = 225
        }
    }

    @objc @IBAction private func dismissPresented(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
}
