//
//  ViewController.swift
//  JSDAlertDialog
//
//  Created by 姜守栋 on 2018/4/17.
//  Copyright © 2018年 Nick.Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var _promptView:UIView?
    
    var _promptLabel:UILabel!
    
    var _table:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.designContentView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func designContentView() {
        
        _promptView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        
        let _promptButton = UIButton(type: UIButtonType.custom)
        _promptButton.frame = CGRect(x: 10, y: 0, width: 36, height: 50)
        _promptButton.setImage(UIImage(named: "sign_noral"), for: UIControlState())
        _promptButton.setImage(UIImage(named: "sign_select"), for: UIControlState.highlighted)
        _promptButton.setImage(UIImage(named: "sign_select"), for: UIControlState.selected)
        
        _promptButton.addTarget(self, action: #selector(ViewController.selectButton(_:)), for: UIControlEvents.touchUpInside)
        
        _promptView!.addSubview(_promptButton)
        
        _promptLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 220, height: 50))
        
        _promptLabel.text      = "我确认，已认真阅读如上提醒！^_^";
        _promptLabel.textColor = UIColor.red
        _promptLabel.font      = UIFont.systemFont(ofSize: 14)
        
        _promptView!.addSubview(_promptLabel)
        
        
        _table = UITableView(frame: CGRect(x: 0, y: 0, width: 300, height: 300), style: UITableViewStyle.plain)
        _table.delegate = self
        _table.dataSource = self
        
        
    }
    
    @IBAction func showNormal(_ sender: AnyObject) {
        
        // 创建alert
        let alert = AlertDialog(title: "提示", message: "卡的身份暗淡咖啡及阿尔基金安抚啊发简历到开封卡时间对伐啦拉宽带费拉开到家里阿里快速的房间里卡里的风景", messageColor: UIColor.red)
        
        alert.addButton(ButtonType.button_OTHER, title: "取消") { (item) -> Void in
            print(item.title)
        }
        
        alert.addButton(ButtonType.button_OTHER, title: "确定") { (item) -> Void in
            print(item.title)
        }
        
        alert.show()
        
    }
    
    @IBAction func showCheck(_ sender: AnyObject) {
        // 使用alert
        let alert = AlertDialog(title: "提示", message: "", messageColor: nil)
        alert.contentView = _promptView
        alert.addButton(ButtonType.button_OTHER, title: "取消") { (item) -> Void in
            print(item.title)
        }
        
        alert.addButton(ButtonType.button_OTHER, title: "确定") { (item) -> Void in
            print(item.title)
        }
        
        alert.show()
    }
    
    @IBAction func showTable(_ sender: AnyObject) {
        // 使用alert
        let alert = AlertDialog(title: "提示", message: "", messageColor: nil)
        alert.contentView = _table
        alert.addButton(ButtonType.button_CANCEL, title: "取消") { (item) -> Void in
            print(item.title)
        }
        
        alert.addButton(ButtonType.button_OK, title: "确定") { (item) -> Void in
            print(item.title)
        }
        
        alert.show()
    }
    
    // 自定义的视图响应事件
    @objc func selectButton(_ button:UIButton) {
        if button.isSelected {
            button.isSelected = false
            self._promptLabel.textColor = UIColor.red
        }
        else {
            button.isSelected = true
            self._promptLabel.textColor = UIColor.black
        }
    }
    
    // tableview delegate&datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ce")
        cell.textLabel?.text = "bit it"
        return cell
    }
    
}

