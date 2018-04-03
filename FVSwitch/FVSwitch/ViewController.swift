//
//  ViewController.swift
//  FVSwitch
//
//  Created by james on 2017/10/16.
//  Copyright © 2017年 ACC Inc. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let btn : SwitchControl = SwitchControl.init(isOn: false, frame: NSRect.init(x: 100, y: 100, width: 200, height: 50), textOn: "he", textOff: "NO", tintColor: nil)
        self.view.addSubview(btn)
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

