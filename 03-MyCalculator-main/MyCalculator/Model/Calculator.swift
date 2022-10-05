//
//  Calculator.swift
//  MyCalculator
//
//  Created by 钱正轩 on 2020/10/20.
//

import Foundation

class Calculator{
    var inputBuffer = InputBuffer()
    var binaryStack = BinaryStack()
    var memory = Memory()
    var mainRegister = 0.0
    var prev:(op:BinaryOperator, operand:Double)?
    
    
    func calculate(_ op:Operator) -> Double{
        switch op{
        case let .input(symbol):
            inputBuffer.append(symbol)
            mainRegister = inputBuffer.value ?? Double.nan
        case let .function(fop):
            functionalHandler(fop)
            inputBuffer.reset()
        case let .binary(bop):
            prev = (bop, mainRegister)
            binaryStack.push(bop, mainRegister)
            if let last = binaryStack.peek{
                mainRegister = last.operand
            }
            inputBuffer.reset()
        case let .unary(uop):
            mainRegister = uop.op(mainRegister)
            inputBuffer.reset()
        }
        return mainRegister
    }
    
    func functionalHandler(_ op:FunctionOperator){
        switch op {
        case .ac:
            inputBuffer.reset()
            binaryStack.reset()
//            memory.reset()
            mainRegister = 0.0
            prev = nil
        case .eq:
            if !binaryStack.isEmpty{
                mainRegister = binaryStack.evaluate(mainRegister)
            } else {
                if let p = prev{
                    mainRegister = p.op.op(mainRegister, p.operand)
                }
            }
        case .mr:
            mainRegister = memory.memory
        default:
            memory.calculate(op, mainRegister)
        }
    }
}

struct Memory{
    var memory = 0.0
    
    mutating func calculate(_ op:FunctionOperator, _ operand:Double){
        switch op{
        case .mc:
            memory = 0.0
        case .mp:
            memory = memory + operand
        case .mm:
            memory = memory - operand
        default:
            assert(false)
        }
    }
    
    mutating func reset(){
        memory = 0.0
    }
}

struct BinaryStack{
    var stack = [(op:BinaryOperator,operand:Double)]()
    
    var peek:(op:BinaryOperator,operand:Double)?{
        stack.last
    }
    
    var isEmpty:Bool{
        stack.isEmpty
    }
    
    mutating func push(_ op:BinaryOperator, _ operand:Double){
        if let last = peek{
            if op.precedence < last.op.precedence{
                stack.append((op, operand))
            } else {
                stack.removeLast()
                push(op, last.op.op(last.operand, operand))
            }
        } else {
            stack.append((op, operand))
        }
    }
    
    mutating func evaluate(_ operand:Double) -> Double{
        var result = operand
        while !stack.isEmpty{
            let last = stack.removeLast()
            result = last.op.op(last.operand, result)
        }
        return result
    }
    
    mutating func reset(){
        stack.removeAll()
    }
}

struct InputBuffer{
    var hasDot = false
    var buffer = ""
    
    var value:Double?{
        Double(buffer)
    }
    
    mutating func append(_ symbol:InputSymbol){
        switch symbol{
        case .dot:
            if !hasDot{
                buffer += symbol.value
                hasDot = true
            }
        default:
            buffer += symbol.value
        }
        print(Double(buffer) ?? "0.0")
    }
    
    mutating func reset(){
        buffer = ""
        hasDot = false
    }
}
