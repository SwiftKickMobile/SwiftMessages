//
//  CountedMessageView.swift
//  Demo
//
//  Created by Timothy Moose on 8/25/17.
//  Copyright © 2017 SwiftKick Mobile. All rights reserved.
//

import UIKit
import SwiftMessages

class CountedMessageView: UIView, Identifiable {

    @IBOutlet weak var countLabel: UILabel!

    var id: String {
        return "counted"
    }
}
