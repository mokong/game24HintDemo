# 《24点》APP——提示功能实现

## 背景

打算做《挑战24点》，调研了商店里现存的24点APP。大部分的盈利逻辑是：
1. 设置闯关模式，通过闯关增加趣味性，吸引用户活跃度，通过底部banner广告和后台唤起广告盈利
2. 提示的获取，通过限制提示次数，超出次数后观看广告或者购买来解锁额外次数。

这里分享一下，《24点》APP提示功能如何实现，效果如下：

![demo1](https://raw.githubusercontent.com/mokong/BlogImages/main/img/PageCallback.gif)

提示功能实现又分为两步，步骤如下：

1. 判断结果能不能等于24；
   - 笔者一开始认为《24点》APP的4个数字是完全随机的，但完全随机会导致可能计算不出24的情况，对于用户来说，花时间思考了很久但是最终发现是题目不能等于24，容易打击积极性。所以对于刚开始的用户来说，首先要保证随机出的数字一定是要等于24，实现逻辑就是，每次随机出4个数字后，在显示出来之前判断，是否等于24，如果不等于则再次生成随机数字，直到随机出的数字可以等于24时才显示到屏幕上。
   - 但是对于部分想要挑战高难度的用户来说，随机过程中出现不能计算出结果的反而更具有挑战性。所以可以通过在设置中做个Switch开关，开启代表生成的随机数字一定能计算出24，关闭表示不一定能，默认开启，用户可自由选择难度。

2. 如果能等于24，显示出能得到24的表达式；如果不能，提示用户当前随机数字不能得到24。这个步骤中，需要注意的是，计算过程中数字是小数还是整数？表达式中数字的显示等。
   - 计算过程中数字的类型。首先随机生成4个数字是整数。而通过整数去运算，在Swift中，当运算符左右都为整数时，其结果也是整数。这种情况就会导致计算失败，比如：((15 + 1)* (3 / 2))，通过整数计算最终是16，而通过小数计算是24，所以，不能通过整数计算，运算的第一步就是把随机的4个数字转为小数。
   - 表达式中数字的显示。而将数字转为 double 后，最后表达式中数字的显示会带有精度，在添加到表达式中时不能直接使用 `String(format:"%f")`，要使用 NSNumber 进行转换一次，然后再转 String。


下面详细记录一下实现的过程：

## 解法原理

### 步骤一，判断能不能等于24

每次随机数字的逻辑在这里就不详细展开了，下面主要分享下，给定4个数字，如何判断这4个数字能不能等于24。

有[a, b, c, d] 四个数字，任取两个数字，通过遍历运算符得到运算结果 e，然后把运算结果和剩余的数字放入新的数组中，重复上面的计算过程，直到数组中有一个元素为止；最后判断数组中唯一的数字是否等于24即可。

这里需要注意几点，一是遍历运算符的时候，加和乘符合交换律，所以不需要重复计算；二是除法会有小数，所以最终判断是否等于24的时候，需要通过设置误差范围来判断；再有就是除法的除数不能为零。

所以最终解法描述如下：

1. 定义误差范围，定义要对比的值，定义运算符数组；
2. 定义判断是否相等的判断方法，传入值和要对比的值的绝对值小于误差范围，即视作相等；
3. 数据转换，由于传入的数字是Int，所以通过 map 转为 Double 类型；
4. 实现计算方法
   1. 数组为空，不合法；
   2. 数组中只有一个数字，即停止，调用判断相等方法判断是否相等
   3. 从数组中依次取两个数字，两个数字不能相等
   4. 把余下的数字放入新的数组中
   5. 遍历运算符数组
      1. 运算符为"+"或"*"时，注意交换律，刚开始 i < j，所以到 i > j 时，就不需要重复计算了
      2. 运算符为"-"时，除数不能为0
      3. 把取出的两个数字通过运算符计算出结果，放入余下数字的新数组中，新数组中即有3个数字
      4. 再从这个新数组中取出两个数字重复上面的计算过程，递归调用，得到返回结果
      5. 如果返回结果不为真，则从3个数字的新数组中，移除最后一个元素即此次通过运算符运算后的数字；然后再继续遍历下一个运算符
   6. 如果所有运算符已遍历完成，结果还不为真，则继续遍历原始数组，取出后面的数字。


流程图如下：

![24点算法](https://raw.githubusercontent.com/mokong/BlogImages/main/img/24%E7%82%B9%E7%AE%97%E6%B3%95.png)

代码实现如下：


``` Swift

// 1. 定义误差范围，定义要对比的值，定义运算符数组；
let elipson = 0.001
let TargetReuslt = 24
let OperationList = ["+", "-", "*", "/"]

class Solution {
    // 2. 定义判断是否相等的判断方法，传入值和要对比的值的绝对值小于误差范围，即视作相等；
    func isEqual24(_ value: Double) -> Bool {
        return abs(value - Double(TargetReuslt)) < elipson
    }

    func judgePoint24(_ list: [Int]) -> Bool {
        // 3. 数据转换，由于传入的数字是Int，所以通过 map 转为 Double 类型；
        let resultList: [Double] = list.map({ Double($0) })
        return find24(resultList)
    }

    // 每次都是选取两张牌
    func find24(_ cards: [Double]) -> Bool {
        // 4.1 数组为空，不合法；
        if cards.count == 0 {
            return false
        }

        // 4.2 数组中只有一个数字，即停止，调用判断相等方法判断是否相等
        if cards.count == 1 {
            let result = isEqual24(cards[0])
            return result
        }

        let count = cards.count
        // 4.3 从数组中依次取两个数字，两个数字不能相等
        for i in 0..<count {
            for j in 0..<count {
                if i != j {
                    let a = cards[i]
                    let b = cards[j]

                    // 4.4 把余下的数字放入新的数组中
                    var restCards: [Double] = []
                    for k in 0..<count {
                        if k != i && k != j {
                            restCards.append(cards[k])
                        }
                    }

                    // 4.5 遍历运算符数组
                    for op in OperationList {
                        // 4.5.1 运算符为"+"或"*"时，注意交换律，刚开始 i < j，所以到 i > j 时，就不需要重复计算了
                        if ((op == "+" || op == "*") && (i > j)) {
                            // "+"、"*", a + b = b + a, no need to recalculate
                            continue
                        }

                        // 4.5.2 运算符为"-"时，除数不能为0
                        if (op == "/") && b < elipson {
                            // "/" dividend can not equal to zero
                            continue
                        }

                        // 4.5.3 把取出的两个数字通过运算符计算出结果，放入余下数字的新数组中，新数组中即有3个数字
                        switch op {
                            case "+":
                                restCards.append(a+b)
                            case "-":
                                restCards.append(a-b)
                            case "*":
                                restCards.append(a*b)
                            case "/":
                                restCards.append(a/b)
                            default:
                                break
                        }

                        // 4.5.4 再从这个新数组中取出两个数字重复上面的计算过程，递归调用，得到返回结果
                        let result = find24(restCards)
                        if result == true {
                            return true
                        }

                        // 4.5.5 如果返回结果不为真，则从3个数字的新数组中，移除最后一个元素即此次通过运算符运算后的数字；然后再继续遍历下一个运算符
                        restCards.removeLast()
                    }
                }
            }
        }
        return false
    }
}

```

### 步骤二，获得等于24时的表达式

上面的逻辑计算出能否等于24，那在计算出24的情况下，如何把得到这个结果的表达式显示出来？

回过头来看上面的代码，在步骤4.5.3时，进行了表达式和运算符计算的操作，所以如果想要得到计算的表达式的话，需要在这个计算地方把表达式也存储一下。

然后问题是，计算过程是一个递归的过程，如何在递归的过程中保证前面步骤的表达式不丢失，从而得到递归过程中所有计算的表达式，最终在得到结果时，得到一个表达式数组。

修改`func find24(_ cards: [Double]) -> Bool`方法，传入参数中增加`resultExpressList`参数，类型为数组，用于保存每次递归的表达式；传出参数改为增加数组，用于获取最终计算出结果时的表达式。

需要注意：
- `func find24(_ cards: [Double]) -> Bool`返回类型为元组
- 传入表达式数组不可变，故而需要转为可变的
- 表达式的中数字使用 NSNumber转换，避免浮点精度问题

代码如下：

``` Swift

// 1. 定义误差范围，定义要对比的值，定义运算符数组；
let elipson = 0.001
let TargetReuslt = 24
let OperationList = ["+", "-", "*", "/"]

class Solution {
    // 2. 定义判断是否相等的判断方法，传入值和要对比的值的绝对值小于误差范围，即视作相等；
    func isEqual24(_ value: Double) -> Bool {
        return abs(value - Double(TargetReuslt)) < elipson
    }

    func judgePoint24(_ list: [Int]) -> Bool {
        // 3. 数据转换，由于传入的数字是Int，所以通过 map 转为 Double 类型；
        let resultList: [Double] = list.map({ Double($0) })
        let value: (result: Bool, expressList: [String]) = find24(resultList, resultExpressList: [])
        return value.result
    }

    // 每次都是选取两张牌
    func find24(_ cards: [Double], resultExpressList: [String]) -> (Bool, [String]) {
        // 4.1 数组为空，不合法；
        if cards.count == 0 {
            return (false, resultExpressList)
        }

        // 4.2 数组中只有一个数字，即停止，调用判断相等方法判断是否相等
        if cards.count == 1 {
            let result = isEqual24(cards[0])
            return (result, resultExpressList)
        }
        
        // 将传入数据变为可变数组
        var expressionList: [String] = []
        expressionList.append(contentsOf: resultExpressList)

        let count = cards.count
        // 4.3 从数组中依次取两个数字，两个数字不能相等
        for i in 0..<count {
            for j in 0..<count {
                if i != j {
                    let a = cards[i]
                    let b = cards[j]

                    // 4.4 把余下的数字放入新的数组中
                    var restCards: [Double] = []
                    for k in 0..<count {
                        if k != i && k != j {
                            restCards.append(cards[k])
                        }
                    }

                    // 4.5 遍历运算符数组
                    for op in OperationList {
                        // 4.5.1 运算符为"+"或"*"时，注意交换律，刚开始 i < j，所以到 i > j 时，就不需要重复计算了
                        if ((op == "+" || op == "*") && (i > j)) {
                            // "+"、"*", a + b = b + a, no need to recalculate
                            continue
                        }

                        // 4.5.2 运算符为"-"时，除数不能为0
                        if (op == "/") && b < elipson {
                            // "/" dividend can not equal to zero
                            continue
                        }

                        // 4.5.3 把取出的两个数字通过运算符计算出结果，放入余下数字的新数组中，新数组中即有3个数字
                        // 计算后，将表达式保存到 expressionList 中，并作为下次递归的参数
                        // 注意：表达式的中数字使用 NSNumber，避免浮点精度问题
                        switch op {
                            case "+":
                                restCards.append(a+b)
                                expressionList.append(String(format: "(%@ + %@) = %@", NSNumber(value: a), NSNumber(value: b), NSNumber(value: a + b)))
                            case "-":
                                restCards.append(a-b)
                                expressionList.append(String(format: "(%@ - %@) = %@", NSNumber(value: a), NSNumber(value: b), NSNumber(value: a - b)))
                            case "*":
                                restCards.append(a*b)
                                expressionList.append(String(format: "(%@ * %@) = %@", NSNumber(value: a), NSNumber(value: b), NSNumber(value: a * b)))
                            case "/":
                                restCards.append(a/b)
                                expressionList.append(String(format: "(%@ / %@) = %@", NSNumber(value: a), NSNumber(value: b), NSNumber(value: a / b)))
                            default:
                                break
                        }

                        // 4.5.4 再从这个新数组中取出两个数字重复上面的计算过程，递归调用，得到返回结果
                        let resultValue: (result: Bool, list: [String]) = find24(tempList, resultExpressList: expressionList, level: level)
                        if resultValue.result {
                            return (true, resultValue.list)
                        }

                        // 4.5.5 如果返回结果不为真，则从3个数字的新数组中，移除最后一个元素即此次通过运算符运算后的数字；然后再继续遍历下一个运算符
                        restCards.removeLast()
                    }
                }
            }
        }
        return false
    }
}

```

测试上面的代码：

给定[6, 8, 5, 8]四个数字，判断能否等于24，如果能，打印表达式，最终打印出的表达式数组如下：

``` Swift

["(6 - 8) = -2", "(5 + -2) = 3", "(8 * 3) = 24"]

```

从上面打印出的日志可以看到，确实可以计算出24，且把计算出24过程保存下来了，但是跟想象中的不一样，因为同类型《24点》APP的提示功能中，提示的表达式是把步骤合一，最后是一个整体的表达式，而不是分步骤的，所以要怎么把这个步骤合一呢？

再看一遍上面的数字和表达式数组：

``` Swift

数字：              [6, 8, 5, 8]
表达式数组：  ["(6 - 8) = -2", "(5 + -2) = 3", "(8 * 3) = 24"]

```

要做的就是把表达式数组换成一个完整的表达式：
- 把5+ -2中的-2替换为(6 - 8)
- 把8 * 3中的3替换为(5 + (6- 8))，从而得到最终的(8 * (5 + (6 - 8)))

这个转换需要注意两点：
1. 每个数组只能用一遍
2. 每个表达式只能用一次

笔者这里转换的步骤如下：

- 定义一个字典数组，用于存储每一步转换的字典
- 遍历上面的表达式数组
  - 定义一个字典，三个 key，表达式，表达式结果，表达式是否使用过，{"expressionStr": "a + b", "expressionValue": "c", "expressionUsed": "0"}
  - 将表达式和结果分开，存储到字典里，默认没使用过，并且存储到字典数组中
  - 遍历非第一个元素时
    - 遍历字典数组，判断是否使用过，元素是否包含字典表达式元素的值，
      - 包含则把元素中对应的值替换为字典表达式元素的表达式，且标记字典表达式为使用过，且把新的字典存储到字典数组中
      - 不包含，则把新的字典存储到字典数组中
- 最后返回字典数组最后一个元素的表达式，即是所需结果

流程图如下：

![表达式数组转表达式](https://raw.githubusercontent.com/mokong/BlogImages/main/img/%E6%9C%AA%E5%91%BD%E5%90%8D%E6%96%87%E4%BB%B6.png)

代码如下：

``` Swift

func generateExpressStr(from list: [String]) -> String {
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

```

通过上面的步骤就可以得到完整的计算表达式，但是还有可以优化的地方，比如表达式：`(8 * (5 + (6 - 8)))`，虽然对应程序来说，计算步骤是先计算`6-8`，然后计算`5-2`，最后计算`8*3`，但是对于用户来说，其实不关心计算步骤，用户感受到的是，是不是更符合数学表达式的逻辑，即对于上面的表达式来说，不需要括号，即`8 * (5 + 6 - 8)`，这样更符合数学表达式的概念，运算符优先级都相同时，加括号和不加括号，并没有什么区别，最外层的括号也没有意义。所以要如何做呢？这个优化留给大家来发挥。提示：方法一，可以通过在上面的转换步骤中解决，每次转换前判断运算符优先级决定是否去除括号。方法二：先转换，然后再遍历表达式，遍历过程中没有运算符优先级相同的，可以去除括号。

### 完整代码

本篇的完整代码已整理放在[Github](https://github.com/mokong/game24HintDemo)，链接如下：
https://github.com/mokong/game24HintDemo


最终效果如下：

![game24DemoImage](https://raw.githubusercontent.com/mokong/BlogImages/main/img/game24demo.gif)

## 结语

`Swift 后缀表达式`和`24点提示功能的实现`两篇文章，介绍了做一个《24点 APP》所需的基本功能，通过`Swift 后缀表达式`可以计算任意算术表达式的结果，通过`24点提示功能的实现`可以通过数字获得计算表达式。有了这两个功能就可以做出一个简单的《24点 APP》。感兴趣的可以通过体验商店里现有的同类型APP，比较 APP 之间的差异以及给人的体验感受，然后设计自己的UI、动效，加上独有的功能实现，比如换肤、闯关、内购等等，可以做出自己的独特的《24点 APP》，欢迎尝试。



