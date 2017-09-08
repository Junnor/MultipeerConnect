//
//  ViewController.swift
//  ColorColor
//
//  Created by ju on 2017/9/7.
//  Copyright © 2017年 ju. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var connectionsLabel: UILabel!
    
    let colorService = ColorServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        colorService.delegate = self
        
    }
    
    
    @IBAction func colorChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            changeTo(color: .black)
            colorService.send(colorName: "black")
        case 1:
            changeTo(color: .gray)
            colorService.send(colorName: "gray")
        case 2:
            changeTo(color: .lightGray)
            colorService.send(colorName: "lightGray")
        default: break
        }
        
    }
    
    fileprivate func changeTo(color: UIColor) {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = color
        }
    }
    
}

extension ViewController: ColorServiceManagerDelegate {
    
    func colorChanged(manager: ColorServiceManager, colorString: String) {
        OperationQueue.main.addOperation {
            switch colorString {
            case "black": self.changeTo(color: .black)
            case "gray": self.changeTo(color: .gray)
            case "lightGray": self.changeTo(color: .lightGray)
            default: break
            }
            
        }
        
    }
    
    func connectedDevicesChanged(managr: ColorServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
}

