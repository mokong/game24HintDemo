//
//  ViewController.swift
//  Game24HintDemo
//
//  Created by Horizon on 26/4/2022.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - properties
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    
    fileprivate var btnList: [UIButton] = []
    fileprivate var numberList: [Int] = []
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigaitonItems()
        setupSubviews()
        generateRandomNumber()
    }

    // MARK: - init
    fileprivate func setupNavigaitonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "换一组", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleRandomNumber(_:)))
    }
    
    fileprivate func setupSubviews() {
        btnList = [btn1, btn2, btn3, btn4]
    }
    
    // MARK: - utils
    fileprivate func generateRandomNumber() {
        numberList = []
        for _ in 0..<4 {
            let number = Int.random(in: 1..<9)
            numberList.append(number)
        }

        for index in 0..<4 {
            let btn = btnList[index]
            let num = numberList[index]
            
            btn.setTitle(String(format: "%ld", num), for: UIControl.State.normal)
        }
    }
    
    func handleGetHint() {
        var hintStr = ""
        let result = Game24Util.judgePoint24(self.numberList)
        let resultFirst = "结果："
        let resultDetail = "计算步骤："

        if result == true {
            let tempValue: (first: String, list: [String]) = getHintExpressionStr()
            hintStr = tempValue.first
            hintStr = resultFirst + "\n\n" + hintStr + " = 24\n\n\n\n" + resultDetail + "\n\n" + tempValue.list.joined(separator: "\n\n")
        }
        else {
            hintStr = String(format: "%@不能计算出24", self.numberList.description)
        }
        let hintVC = Game24HintVC(hintStr)
        self.navigationController?.present(hintVC, animated: true, completion: nil)
    }
    
    func getHintExpressionStr() -> (String, [String]) {
        let targetList = numberList.map { value in
            return Double(value)
        }
        let tempValue: (first: Bool, list: [String]) = Game24Util.find24(targetList, resultExpressList: [])
        let str = Game24Util.generateExpressStr(from: tempValue.list)
        return (str, tempValue.list)
    }
    
    // MARK: - action
    
    @objc fileprivate func handleRandomNumber(_ sender: UIButton?) {
        generateRandomNumber()
    }
    
    @IBAction func getHint(_ sender: Any) {
        handleGetHint()
    }
    
    // MARK: - other
    



}

