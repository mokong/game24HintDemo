//
//  Game24Util.swift
//  game24
//
//  Created by MorganWang on 15/2/2022.
//

import Foundation

let elipson = 0.001
let TargetReuslt = 24
let operations = ["+", "-", "*", "/"]

enum Game24Level: Int {
    case low = 0
    case medium
    case high
}

class Game24Util {
    
    static func isEqual24(_ value: Double) -> Bool {
        return abs(value - Double(TargetReuslt)) < elipson
    }
    
    static func generateExpressStr(from list: [String]) -> String {
        var resultStrList: [NSMutableDictionary] = []
        let strKey = "expressionStr"
        let valueKey = "expressionValue"
        let statusKey = "expressionUsed"

        var newResultStrList: [NSMutableDictionary] = []
        for index in 0..<list.count {
            let itemStr = list[index]
            
            let componentList = itemStr.components(separatedBy: " = ")
            var expressionStr = componentList[0]
            let expressionValue = componentList[1]
            
            if index == 0 {
                let tempDic = NSMutableDictionary()
                tempDic.setValue(expressionStr, forKey: strKey)
                tempDic.setValue(expressionValue, forKey: valueKey)
                tempDic.setValue("0", forKey: statusKey)
                newResultStrList.append(tempDic)
            }
            else {
                for itemDic in resultStrList {
                    print(itemDic)
                    if let previousExpressionStr = itemDic.value(forKey: strKey) as? String,
                       let previousExpressionValueStr = itemDic.value(forKey: valueKey) as? String,
                       let previousStatusValue = itemDic.value(forKey: statusKey) as? String,
                       previousStatusValue == "0" {
                        let tempDic = NSMutableDictionary()
                        if expressionStr.contains(previousExpressionValueStr) {
                            let range = (expressionStr as NSString).range(of: previousExpressionValueStr)
                            let newExpressionStr = (expressionStr as NSString).replacingCharacters(in: range, with: previousExpressionStr)
//                            let newExpressionStr = expressionStr.replacingOccurrences(of: previousExpressionValueStr, with: previousExpressionStr)
                            expressionStr = newExpressionStr
                            let newExpressionValue = expressionValue
                            tempDic.setValue(newExpressionStr, forKey: strKey)
                            tempDic.setValue(newExpressionValue, forKey: valueKey)
                            tempDic.setValue("0", forKey: statusKey)
                            newResultStrList.append(tempDic)
                            
                            itemDic.setValue("1", forKey: statusKey)
                        }
                        else {
                            let newExpressionStr = expressionStr
                            let newExpressionValue = expressionValue
                            let tempDic = NSMutableDictionary()
                            tempDic.setValue(newExpressionStr, forKey: strKey)
                            tempDic.setValue(newExpressionValue, forKey: valueKey)
                            tempDic.setValue("0", forKey: statusKey)
                            newResultStrList.append(tempDic)
                        }
                    }
                }
            }
            resultStrList = newResultStrList
        }
        let resultStr = resultStrList.last?.value(forKey: strKey) as? String ?? ""
        print(resultStr)
        return resultStr
    }
        
    static func judgePoint24(_ list: [Int]) -> Bool {
        var resultList: [Double] = []
        for item in list {
            resultList.append(Double(item))
        }
        let value: (result: Bool, expressList: [String]) = Game24Util.find24(resultList, resultExpressList: [])
        return value.result
    }

    // 每次都是选取两张牌
    static func find24(_ list: [Double], resultExpressList: [String]) -> (Bool, [String]) {
        if list.count == 0 {
            return (false, resultExpressList)
        }
        
        if (list.count == 1) {
            // 如果此时 list 只剩下了一张牌
            let result = Game24Util.isEqual24(list[0])
            if result == true {
                print(resultExpressList)
            }
            return (result, resultExpressList)
        }
        
        var expressionList: [String] = []
        expressionList.append(contentsOf: resultExpressList)

        // 选取两张牌
        let count = list.count
        for i in 0..<count {
            for j in 0..<count { // each time we pick up two number for computation
                if i != j {
                    let a = list[i]
                    let b = list[j]
                    
                    // 对于每下一个可能的产生的组合
                    var tempList: [Double] = []
                    
                    for k in 0..<count {
                        if k != i && k != j {
                            tempList.append(list[k])
                        }
                    }
                    
                    for op in operations {
                        if ((op == "+" || op == "*") && i > j) { // no need to re-calculate
                            continue;
                        }

                        if op == "/" && b <= elipson { // 除数不能为0
                            continue
                        }
                                        
                        switch op {
                        case "+":
                            tempList.append(a + b)
                            expressionList.append(String(format: "(%@ + %@) = %@", NSNumber(value: a), NSNumber(value: b), NSNumber(value: a + b)))
                        case "-":
                            tempList.append(a - b)
                            expressionList.append(String(format: "(%@ - %@) = %@", NSNumber(value: a), NSNumber(value: b), NSNumber(value: a - b)))
                        case "*":
                            tempList.append(a * b)
                            expressionList.append(String(format: "(%@ * %@) = %@", NSNumber(value: a), NSNumber(value: b), NSNumber(value: a * b)))
                        case "/":
                            tempList.append(a / b)
                            expressionList.append(String(format: "(%@ / %@) = %@", NSNumber(value: a), NSNumber(value: b), NSNumber(value: a / b)))
                        default:
                            break
                        }
                        
                        let resultValue: (result: Bool, list: [String]) = find24(tempList, resultExpressList: expressionList)
                        if resultValue.result {
                            return (true, resultValue.list)
                        }
                        
                        expressionList.removeLast()
                        tempList.removeLast()
                    }
                }
            }
        }
        return (false, expressionList)
    }
}
