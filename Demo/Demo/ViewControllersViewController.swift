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
    @objc @IBAction private func dismissPresented(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
}
