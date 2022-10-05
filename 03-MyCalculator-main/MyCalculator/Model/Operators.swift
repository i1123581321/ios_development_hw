//
//  Operators.swift
//  MyCalculator
//
//  Created by 钱正轩 on 2020/10/20.
//

import Foundation

enum Operator{
    case function(FunctionOperator)
    case binary(BinaryOperator)
    case unary(UnaryOperator)
    case input(InputSymbol)
}

enum FunctionOperator:Int{
    case ac = 1
    case mc
    case mp
    case mm
    case mr
    case eq
}

enum BinaryOperator:Int{
    case divide = 1
    case multiply
    case minus
    case plus
    case powery
    case rooty
    case ee
    
    var op:(Double, Double)->Double{
        switch self{
        case .divide:
            return {$0 / $1}
        case .multiply:
            return {$0 * $1}
        case .plus:
            return {$0 + $1}
        case .minus:
            return {$0 - $1}
        case .powery:
            return pow
        case .rooty:
            return {pow($0, 1 / $1)}
        case .ee:
            return {$0 * pow(10, $1)}
        }
    }
    
    var precedence:Int{
        switch self{
        case .powery, .rooty, .ee:
            return 1
        case .multiply, .divide:
            return 2
        case .plus, .minus:
            return 3
        }
    }
}

enum UnaryOperator:Int{
    case negate = 1
    case persentage
    case power2
    case power3
    case exponential
    case power10
    case reciprocal
    case square
    case cube
    case logarithm
    case logarithm10
    case factorial
    case sine
    case cosine
    case tangent
    case sineh
    case cosineh
    case tangenth
    case e
    case pi
    case rand

    var op:(Double)->Double{
        switch self{
        case .negate:
            return {-$0}
        case .persentage:
            return {$0 * 0.01}
        case .power2:
            return {pow($0, 2)}
        case .power3:
            return {pow($0, 3)}
        case .exponential:
            return exp
        case .power10:
            return {pow(10, $0)}
        case .reciprocal:
            return {1 / $0}
        case .square:
            return sqrt
        case .cube:
            return cbrt
        case .logarithm:
            return log
        case .logarithm10:
            return log10
        case .factorial:
            return {(1...Int($0)).map(Double.init).reduce(1.0, *)}
        case .sine:
            return {sin($0 * Double.pi / 180.0)}
        case .cosine:
            return {sin($0 * Double.pi / 180.0)}
        case .tangent:
            return {tan($0 * Double.pi / 180.0)}
        case .sineh:
            return sinh
        case .cosineh:
            return cosh
        case .tangenth:
            return tanh
        case .e:
            return {n in M_E}
        case .pi:
            return {n in Double.pi}
        case .rand:
            return {n in Double.random(in: 0..<1)}
        }
    }
}

enum InputSymbol:Int{
    case zero = 1
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case dot
    
    var value:String{
        switch self {
        case .zero:
            return "0"
        case .one:
            return "1"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .dot:
            return "."
        }
    }
}
