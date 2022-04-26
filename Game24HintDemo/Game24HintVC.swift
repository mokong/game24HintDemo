//
//  Game24HintVC.swift
//  Game24HintDemo
//
//  Created by Horizon on 26/4/2022.
//

import UIKit
import SnapKit

class Game24HintVC: UIViewController {

    // MARK: - properties
    private(set) var hintStr: String?
    private(set) lazy var closeBtn: UIButton = UIButton(type: UIButton.ButtonType.custom)
    private(set) lazy var hintTextView: UITextView = UITextView(frame: CGRect.zero)
    
    // MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let game24Btn = UIButton(type: UIButton.ButtonType.custom)
        game24Btn.setTitle("game24", for: UIControl.State.normal)
        game24Btn.setTitleColor(UIColor.red, for: .normal)
        game24Btn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        // Do any additional setup after loading the view.
        setupGame24Subviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    deinit {
        let classStr = NSStringFromClass(self.classForCoder)
        print(classStr, "deinit")
    }

    
    // MARK: - init
    init(_ hintStr: String) {
        super.init(nibName: nil, bundle: nil)
        self.hintStr = hintStr
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupGame24Subviews() {
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(8.0)
            make.width.height.equalTo(52.0)
        }
        closeBtn.setTitle("关闭", for: UIControl.State.normal)
        closeBtn.setTitleColor(UIColor.darkGray, for: UIControl.State.normal)
        closeBtn.addTarget(self, action: #selector(handleCloseAction(_:)), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(hintTextView)
        hintTextView.font = UIFont.systemFont(ofSize: 20.0)
        hintTextView.textColor = UIColor.darkGray
        hintTextView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(60.0)
            make.leading.trailing.equalToSuperview().inset(20.0)
        }
        
        hintTextView.isEditable = false
        hintTextView.text = hintStr
    }
    
    // MARK: - utils
    
    
    // MARK: - action
    @objc fileprivate func handleCloseAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - other
    


}

