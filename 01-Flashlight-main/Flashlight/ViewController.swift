//
//  ViewController.swift
//  Flashlight
//
//  Created by 钱正轩 on 2020/9/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var isOn = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var switchButton: UIButton!
    
    @IBAction func eventHandler(){
        if isOn{
            lightOff()
        } else {
            lightOn()
        }
    }
    
    func lightOn(){
        
        mainView.backgroundColor = .white
        switchButton.setTitle("Off", for:.normal)
        switchButton.setTitleColor(.black, for:.normal)
        isOn = true
        if let device = AVCaptureDevice.default(for: .video){
            if device.hasTorch{
                do{
                    try device.lockForConfiguration()
                    device.torchMode = .on
                } catch{
                    print("Touch could not be used")
                }
            } else {
                print("Torch is not available")
            }
        }
    }
    
    func lightOff(){
        mainView.backgroundColor = .black
        switchButton.setTitle("On", for:.normal)
        switchButton.setTitleColor(.white, for:.normal)
        isOn = false
        if let device = AVCaptureDevice.default(for: .video){
            if device.hasTorch{
                do{
                    try device.lockForConfiguration()
                    device.torchMode = .off
                } catch{
                    print("Touch could not be used")
                }
            } else {
                print("Torch is not available")
            }
        }
    }
}

