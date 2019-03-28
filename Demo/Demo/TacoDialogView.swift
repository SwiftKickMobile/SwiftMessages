//
//  TacoDialogView.swift
//  Demo
//
//  Created by Tim Moose on 8/12/16.
//  Copyright © 2016 SwiftKick Mobile. All rights reserved.
//

import UIKit
#if os(iOS)
import SwiftMessages
#else
import SwiftMessagesTvOS
#endif

class TacoDialogView: MessageView {

    fileprivate static var tacoTitles = [
        1 : "Just one, Please",
        2 : "Make it two!",
        3 : "Three!!!",
        4 : "Cuatro!!!!",
    ]

    var getTacosAction: ((_ count: Int) -> Void)?
    var cancelAction: (() -> Void)?
    
    fileprivate var count = 1 {
        didSet {
            iconLabel?.text = String(repeating: "🌮", count: count)//String(count: count, repeatedValue: )
            bodyLabel?.text = TacoDialogView.tacoTitles[count] ?? "\(count)" + String(repeating: "!", count: count)
        }
    }
    
    @IBAction func getTacos() {
        #if os(iOS)
        getTacosAction?(Int(tacoSlider.value))
        #else
        getTacosAction?(1)
        #endif
    }

    @IBAction func cancel() {
        cancelAction?()
    }
    
    #if os(iOS)
    @IBOutlet weak var tacoSlider: UISlider!
    
    @IBAction func tacoSliderSlid(_ slider: UISlider) {
        count = Int(slider.value)
    }
    
    @IBAction func tacoSliderFinished(_ slider: UISlider) {
        slider.setValue(Float(count), animated: true)
    }
    #endif
}
