//
//  ViewController.swift
//  TinyTank
//
//  Created by 钱正轩 on 2020/12/21.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet weak var arView: ARView!
    
    var tankAnchor:TinyToyTank._TinyToyTank?
    var isPlaying = false
    
    @IBAction func turretLeft(_ sender: UIButton) {
        if isPlaying{
            return
        }
        isPlaying = true
        tankAnchor?.notifications.turretLeft.post()
        isPlaying = false
    }
    
    @IBAction func cannonFire(_ sender: UIButton) {
        if isPlaying{
            return
        }
        isPlaying = true
        tankAnchor?.notifications.cannonFire.post()
        isPlaying = false
    }
    
    @IBAction func turretRight(_ sender: UIButton) {
        if isPlaying{
            return
        }
        isPlaying = true
        tankAnchor?.notifications.turretRight.post()
        isPlaying = false
    }
    
    @IBAction func tankLeft(_ sender: UIButton) {
        if isPlaying{
            return
        }
        isPlaying = true
        tankAnchor?.notifications.tankLeft.post()
        isPlaying = false
    }
    
    @IBAction func tankForward(_ sender: UIButton) {
        if isPlaying{
            return
        }
        isPlaying = true
        tankAnchor?.notifications.tankForward.post()
        isPlaying = false
    }
    
    @IBAction func tankRight(_ sender: UIButton) {
        if isPlaying{
            return
        }
        isPlaying = true
        tankAnchor?.notifications.tankRight.post()
        isPlaying = false
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            tankAnchor = try TinyToyTank.load_TinyToyTank()
        } catch {
            print(error.localizedDescription)
        }
        
        // Add the box anchor to the scene
//        arView.scene.anchors.append(tankAnchor!)
        if let anchor = tankAnchor {
            arView.scene.anchors.append(anchor)
        }
    }
}
