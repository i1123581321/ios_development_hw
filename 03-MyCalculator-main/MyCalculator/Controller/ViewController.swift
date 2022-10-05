//
//  ViewController.swift
//  MyCalculator
//
//  Created by 钱正轩 on 2020/10/19.
//

import UIKit

class ViewController: UIViewController {
    
    var calculator = Calculator()
    @IBOutlet weak var outputLable: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func unimplemented(){
        let alert = UIAlertController(title: "未实现", message: "该操作仍在开发中", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func opHandler(_ op:Operator){
        let value = calculator.calculate(op)
        if value.isFinite {
            let isDecimalZero = value.truncatingRemainder(dividingBy: 1) == 0
            let length = isDecimalZero ? String(value).count - 2 : String(value).count - 1
            if length > 8{
                outputLable.text = String(format: "%.8g", value)
            } else {
                if isDecimalZero{
                    outputLable.text = String(format: "%.0f", value)
                } else {
                    outputLable.text = String(value)
                }
            }
        } else {
            outputLable.text = "错误"
        }
    }

    @IBAction func unaryTouched(_ sender: UIButton) {
        if let op = UnaryOperator(rawValue: sender.tag){
            print(op)
            opHandler(.unary(op))
        } else {
            unimplemented()
        }
    }
    
    @IBAction func binaryTouched(_ sender: UIButton) {
        if let op = BinaryOperator(rawValue: sender.tag){
            print(op)
            opHandler(.binary(op))
        } else {
            unimplemented()
        }
    }
    
    
    @IBAction func functionTouched(_ sender: UIButton) {
        if let op = FunctionOperator(rawValue: sender.tag){
            print(op)
            opHandler(.function(op))
        } else {
            unimplemented()
        }
    }
    
    
    @IBAction func inputTouched(_ sender: UIButton) {
        if let op = InputSymbol(rawValue: sender.tag){
            print(op)
            opHandler(.input(op))
        } else {
            unimplemented()
        }
    }
}

