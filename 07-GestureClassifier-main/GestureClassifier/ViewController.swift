//
//  ViewController.swift
//  GestureClassifier
//
//  Created by 钱正轩 on 2020/12/15.
//

import UIKit
import CoreMotion
import CoreML
import AudioToolbox

let samplesPerSecond = 25.0
let numberOfFeatures = 6
let windowSize = 20
let windowOffset = 5
let numberOfWindows = windowSize / windowOffset
let bufferSize = windowSize + windowOffset * (numberOfWindows - 1)
let windowSizeAsBytes = windowSize * 8
let windowOffsetAsBytes = windowOffset * 8
let upperBound = 200
let lowerBound = -60

let activities = ["drive_it","chop_it", "rest_it", "shake_it"]

class ViewController: UIViewController {
    
    @IBOutlet weak var randomLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBAction func randomHandler(_ sender: UIButton) {
        randomLabel.text = activities.randomElement()
        
    }
    
    
    @IBAction func startHandler(_ sender: UIButton) {
        enableMotionUpdate()
    }
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let modelInput = makeMultiArray(numberOfSamples: windowSize)!
    let buffer = makeMultiArray(numberOfSamples: bufferSize)!
    
    var bufferIndex = 0
    var counter = lowerBound{
        willSet{
            if newValue == 0 {
                vibrate()
                isDataAvaliable = true
            }
            if newValue == upperBound {
                vibrate()
                isDataAvaliable = false
                disableMotionUpdate()
                print(predictions)
                DispatchQueue.main.async {
                    self.resultLabel.text = self.predictions.max {a , b in
                        a.value < b.value
                    }?.key
                }
            }
        }
    }
    
    var isDataAvaliable = false
    var predictions = [String:Int]()
    
    let model: GestureClassifier = {
        do {
            let config = MLModelConfiguration()
            return try GestureClassifier(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create model")
        }
    }()
    
    var hiddenIn:MLMultiArray?
    var cellIn:MLMultiArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // make 1 * samples * 6 array
    static private func makeMultiArray (numberOfSamples:Int) -> MLMultiArray? {
        try? MLMultiArray(shape: [1, numberOfSamples, numberOfFeatures] as [NSNumber], dataType: .double)
    }
    
    private func fillBuffer(motionData: CMDeviceMotion){
        for offset in [0, windowSize]{
            let index = bufferIndex + offset
            if index >= bufferSize{
                continue
            }
            addToBuffer(index, 0, motionData.rotationRate.x)
            addToBuffer(index, 1, motionData.rotationRate.y)
            addToBuffer(index, 2, motionData.rotationRate.z)
            addToBuffer(index, 3, motionData.userAcceleration.x)
            addToBuffer(index, 4, motionData.userAcceleration.y)
            addToBuffer(index, 5, motionData.userAcceleration.z)
        }
    }
    
    private func addToBuffer(_ index: Int, _ feature: Int, _ data: Double){
        buffer[[0, index, feature] as [NSNumber]] = NSNumber(value: data)
    }
    
    func enableMotionUpdate(){
        bufferIndex = 0
        counter = lowerBound
        for activity in activities {
            predictions[activity] = 0
        }
        resultLabel.text = ""
        
        motionManager.deviceMotionUpdateInterval = 1 / samplesPerSecond
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: queue, withHandler: {[weak self] data, error in
            guard let self = self, let motionData = data else {
                let errorText = error?.localizedDescription ?? "Unknown"
                print("Device motion update error: \(errorText)")
                return
            }
            self.fillBuffer(motionData: motionData)
            self.bufferIndex = (self.bufferIndex + 1) % windowSize;
            self.counter += 1
            self.predict()
        })
    }
    
    func disableMotionUpdate(){
        motionManager.stopDeviceMotionUpdates()
    }
    
    func vibrate(){
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
    
    func predict() {
        if isDataAvaliable && bufferIndex % windowOffset == 0 && bufferIndex + windowOffset <= windowSize {
            let window = bufferIndex / windowOffset
            memcpy(modelInput.dataPointer, buffer.dataPointer.advanced(by: window * windowOffsetAsBytes), windowSizeAsBytes)
            if let prediction = try? model.prediction(features: modelInput, hiddenIn: hiddenIn, cellIn: cellIn){
                hiddenIn = prediction.hiddenOut
                cellIn = prediction.cellOut
                predictions[prediction.activity]! += 1
            }
        }
    }
}

