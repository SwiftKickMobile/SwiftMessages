//
//  TacoDialogView.swift
//  Demo
//
//  Created by Tim Moose on 8/12/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit
import SwiftMessages

class TacoDialogView: MessageView {

    private static var tacoTitles = [
        1 : "Just one, Please",
        2 : "Make it two!",
        3 : "Three!!!",
        4 : "Cuatro!!!!",
    ]

    var getTacosAction: ((count: Int) -> Void)?
    var cancelAction: (() -> Void)?
    
    private var count = 1 {
        didSet {
            iconLabel?.text = String(count: count, repeatedValue: "🌮" as Character)
            titleLabel?.text = TacoDialogView.tacoTitles[count] ?? "\(count)" + String(count: count, repeatedValue: "!" as Character)
        }
    }
    
    @IBAction func getTacos() {
        getTacosAction?(count: Int(tacoSlider.value))
    }

    @IBAction func cancel() {
        cancelAction?()
    }
    
    @IBOutlet weak var tacoSlider: UISlider!
    
    @IBAction func tacoSliderSlided(slider: UISlider) {
        count = Int(slider.value)
    }
}
