//
//  YOLO.swift
//  SnackLocalization
//
//  Created by 钱正轩 on 2020/11/30.
//

import Foundation
import UIKit
import CoreML

let labels = ["apple", "banana", "cake", "candy", "carrot", "cookie",
              "doughnut", "grape", "hot dog", "ice cream", "juice",
              "muffin", "orange", "pineapple", "popcorn", "pretzel",
              "salad", "strawberry", "waffle", "watermelon"]

class YOLO {
    public static let inputWidth = 224
    public static let inputHeight = 224
    
    struct Prediction {
        let classIndex:Int
        let rect:CGRect
    }
    
    let model: MyModel = {
        do {
            let config = MLModelConfiguration()
            return try MyModel(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create model")
        }
    }()
    
    public init() {}
    
    public func predict(image: CVPixelBuffer) -> Prediction? {
        do{
            let output = try model.prediction(image: image)
            var index = -1
            var prob = -1.0
            for i in 0..<20{
                if output.output1[i].doubleValue > prob {
                    prob = output.output1[i].doubleValue
                    index = i
                }
            }
            let rect = output.output2
            return Prediction(classIndex: index , rect: CGRect(
                                x: rect[0].doubleValue * Double(YOLO.inputWidth),
                                y: rect[2].doubleValue * Double(YOLO.inputHeight),
                                width: (rect[1].doubleValue - rect[0].doubleValue) * Double(YOLO.inputWidth),
                                height: (rect[3].doubleValue - rect[2].doubleValue) * Double(YOLO.inputHeight)))
        } catch {
            print(error)
            return nil
        }
        //        if let output = try? model.prediction(image: image) {
        //            let rect = output.output2
        //            return Prediction(classLabel: output.classLabel, rect: CGRect(
        //                                x: rect[0].doubleValue,
        //                                y: rect[2].doubleValue,
        //                                width: rect[1].doubleValue,
        //                                height: rect[3].doubleValue))
        //        } else {
        //            return nil
        //        }
    }
    
}
