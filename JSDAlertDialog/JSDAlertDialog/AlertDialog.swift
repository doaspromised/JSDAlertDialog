//
//  AlertDialog.swift
//  JSDAlertDialog
//
//  Created by 姜守栋 on 2018/4/17.
//  Copyright © 2018年 Nick.Inc. All rights reserved.
//

import UIKit

let AlertWidth:CGFloat   = 270
let AlertHeight:CGFloat  = 130

let AlertPadding:CGFloat = 10
let MenuHeight:CGFloat   = 44

enum ButtonType {
    case button_OK, button_CANCEL, button_OTHER
}

class AlertDialogItem: NSObject {
    var title:String?
    var type:ButtonType?
    var tag:NSInteger?
    var action:((_ item:AlertDialogItem) -> Void)?
}

//typealias te = (item:AlertDialogItem) -> Void)

class AlertDialog: UIView {
    
    var coverView:UIView?
    var alertView:UIView?
    var labelTitle:UILabel?
    var labelmessage:UILabel?
    
    var buttonScrollView:UIScrollView?
    var contentScrollView:UIScrollView?
    
    var items:NSMutableArray?
    var title:String?
    var message:String?
    
    var buttonWidth:CGFloat?
    var contentView:UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // 便利构造函数
    convenience init(title:String, message:String, messageColor:UIColor?) {
        
        // 计算frame
        var screenWidth  = UIScreen.main.bounds.size.width
        var screenHeight = UIScreen.main.bounds.size.height
        // On iOS7, screen width and height doesn't automatically follow orientation
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 {
            let interfaceOrientation = UIApplication.shared.statusBarOrientation
            if UIInterfaceOrientationIsLandscape(interfaceOrientation) {
                let tmp = screenWidth
                screenWidth = screenHeight
                screenHeight = tmp
            }
        }
        let rect = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        self.init(frame: rect)
        self.items = NSMutableArray()
        self.title = title
        self.message = message
        
        // 设置views
        self.buildViews(messageColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func buildViews(_ color:UIColor?) {
        self.coverView = UIView(frame: self.topView().bounds)
        self.coverView?.backgroundColor = UIColor.black
        self.coverView?.alpha = 0
        self.coverView?.autoresizingMask = UIViewAutoresizing.flexibleHeight
        self.topView().addSubview(self.coverView!)
        
        self.alertView = UIView(frame: CGRect(x: 0, y: 0, width: AlertWidth, height: AlertHeight))
        self.alertView?.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.alertView?.layer.masksToBounds = true
        self.alertView?.layer.cornerRadius  = 5
        self.alertView?.backgroundColor = UIColor.white
        
        self.addSubview(self.alertView!)
        
        // 设置title
        let labelHeigh = self.heighOfRow(self.title! as NSString, font: 17, width: AlertWidth - 2 * AlertPadding)
        self.labelTitle = UILabel(frame: CGRect(x: AlertPadding, y: AlertPadding, width: AlertWidth - 2 * AlertPadding, height: labelHeigh))
        self.labelTitle?.font      = UIFont.boldSystemFont(ofSize: 17)
        self.labelTitle?.textColor = UIColor.black
        self.labelTitle?.textAlignment = NSTextAlignment.center
        self.labelTitle?.numberOfLines = 0
        self.labelTitle?.text = self.title
        self.labelTitle?.lineBreakMode = NSLineBreakMode.byCharWrapping
        self.alertView?.addSubview(self.labelTitle!)
        
        // 设置message
        let messageHeigh = self.heighOfRow(self.message! as NSString, font: 14, width: AlertWidth - 2 * AlertPadding)
        self.labelmessage = UILabel(frame: CGRect(x: AlertPadding, y: self.labelTitle!.frame.origin.y + self.labelTitle!.frame.size.height, width: AlertWidth - 2 * AlertPadding, height: messageHeigh + 2 * AlertPadding))
        self.labelmessage?.font = UIFont.systemFont(ofSize: 14)
        
        let mesColor:UIColor = color ?? UIColor.black
        self.labelmessage?.textColor = mesColor
        self.labelmessage?.textAlignment = NSTextAlignment.center
        self.labelmessage?.text = self.message
        self.labelmessage?.numberOfLines = 0
        self.labelmessage?.lineBreakMode = NSLineBreakMode.byCharWrapping
        self.alertView?.addSubview(self.labelmessage!)
        
        self.contentScrollView = UIScrollView(frame: CGRect.zero)
        self.alertView?.addSubview(self.contentScrollView!)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(AlertDialog.deviceOrientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
    }
    
    // dealloc
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    // override func
    
    override func layoutSubviews() {
        self.buttonScrollView?.frame = CGRect(x: 0, y: self.alertView!.frame.size.height-MenuHeight,width: self.alertView!.frame.size.width, height: MenuHeight);
        self.contentScrollView?.frame = CGRect(x: 0, y: self.labelTitle!.frame.origin.y + self.labelTitle!.frame.size.height, width: self.alertView!.frame.size.width, height: self.alertView!.frame.size.height - MenuHeight);
        self.contentView?.frame = CGRect(x: 0,y: 0,width: self.contentView!.frame.size.width, height: self.contentView!.frame.size.height);
        if self.contentView != nil {
            self.contentScrollView?.contentSize = self.contentView!.frame.size;
        }
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        self.addButtonItem()
        if self.contentView != nil {
            self.contentScrollView?.addSubview(self.contentView!)
        }
        self.reLayout()
    }
    
    
    // show and dismiss
    func topView() -> UIView {
        let window = UIApplication.shared.keyWindow
        return (window?.subviews[0])!
    }
    
    func show() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.coverView?.alpha = 0.5
        }, completion: { (finished) -> Void in
            
        })
        self.topView().addSubview(self)
        self.showAnimation()
    }
    
    //------Preoperties------
    func addButtonWithTitle(_ title:String) -> NSInteger {
        let item = AlertDialogItem()
        item.title = title
        item.action = {(ite:AlertDialogItem)->Void in
            print("no action")
        }
        item.type = ButtonType.button_OK
        self.items?.add(item)
        
        return (self.items?.index(of: title))!
    }
    
    func addButton(_ type:ButtonType, title:String, handler:@escaping ((_ item:AlertDialogItem) -> Void)) {
        let item = AlertDialogItem()
        item.title = title
        item.action = handler
        item.type = type
        self.items?.add(item)
        
        item.tag = self.items?.index(of: item)
    }
    
    
    func addButtonItem() {
        self.buttonScrollView = UIScrollView(frame: CGRect(x: 0, y: self.alertView!.frame.size.height -  MenuHeight,width: AlertWidth, height: MenuHeight))
        self.buttonScrollView?.bounces = false
        self.buttonScrollView?.showsHorizontalScrollIndicator = false
        self.buttonScrollView?.showsVerticalScrollIndicator = false
        let width:CGFloat
        if (self.buttonWidth != nil) {
            width = self.buttonWidth!
            let a = CGFloat((self.items?.count)!)
            self.buttonScrollView?.contentSize = CGSize(width: a * width, height: MenuHeight)
        }
        else {
            width = (self.alertView?.frame.size.width)! / CGFloat((self.items?.count)!)
        }
        
        self.items?.enumerateObjects({ (item, idx, stop) in
            let button = UIButton(type: UIButtonType.system)
            button.frame = CGRect(x: CGFloat(idx) * width, y: 1, width: width, height: MenuHeight)
            button.backgroundColor = UIColor.white
            button.layer.shadowColor = UIColor.gray.cgColor
            button.layer.shadowRadius = 0.5
            button.layer.shadowOpacity = 1
            button.layer.shadowOffset = CGSize.zero
            button.layer.masksToBounds = false
            button.tag = 90000 + idx
            
            let ite = item as! AlertDialogItem
            
            button.setTitle(ite.title, for: UIControlState())
            button.setTitle(ite.title, for: UIControlState.selected)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: (button.titleLabel?.font.pointSize)!)
            
            button.addTarget(self, action: #selector(AlertDialog.buttonTouched(_:)), for: UIControlEvents.touchUpInside)
            self.buttonScrollView?.addSubview(button)
            
            // 按钮边框
            if idx != (self.items?.count)! - 1 {
                let seprateLineVer = UIView(frame: CGRect(x: width - 1, y: 0, width: 2, height: MenuHeight))
                seprateLineVer.backgroundColor = UIColor.lightGray
                button.addSubview(seprateLineVer)
            }
            
            let seprateLineHor = UIView(frame: CGRect(x: 0, y: 0, width: self.buttonScrollView!.frame.size.width, height: 1))
            seprateLineHor.backgroundColor = UIColor.lightGray
            self.buttonScrollView?.addSubview(seprateLineHor)
        })
        
        
        self.alertView?.addSubview(self.buttonScrollView!)
    }
    
    @objc func buttonTouched(_ button:UIButton) {
        let item:AlertDialogItem = self.items![button.tag - 90000] as! AlertDialogItem
        if (item.action != nil) {
            item.action!(item)
        }
        self.dismiss()
    }
    
    func reLayout() {
        var plus:CGFloat
        if self.contentView != nil {
            plus = (self.contentView!.frame.size.height) - ((self.alertView?.frame.size.height)! - MenuHeight)
        }
        else {
            plus = (self.labelmessage?.frame.origin.y)! + (self.labelmessage?.frame.size.height)! - ((self.alertView?.frame.size.height)! - MenuHeight)
        }
        plus = max(0, plus)
        let height = min(self.screenBounds().size.height - MenuHeight, (self.alertView?.frame.size.height)! + plus)
        
        self.alertView?.frame = CGRect(x: self.alertView!.frame.origin.x, y: self.alertView!.frame.origin.y, width: AlertWidth, height: height)
        self.alertView?.center = self.center
        self.setNeedsDisplay()
        self.setNeedsLayout()
    }
    
    func dismiss() {
        self.hideAnimation()
    }
    
    func showAnimation() {
        let popAnimation = CAKeyframeAnimation(keyPath: "transform")
        popAnimation.duration = 0.4
        popAnimation.values   = [
            NSValue.init(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 1.0)),
            NSValue.init(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0)),
            NSValue.init(caTransform3D: CATransform3DMakeScale(0.9, 0.9, 1.0)),
            NSValue.init(caTransform3D: CATransform3DIdentity)
        ]
        popAnimation.keyTimes = [0.2, 0.5, 0.75, 1.0]
        popAnimation.timingFunctions = [
            CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut),
            CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut),
            CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        ]
        self.alertView?.layer.add(popAnimation, forKey: nil)
    }
    
    func hideAnimation() {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.coverView?.alpha = 0.0
            self.alertView?.alpha = 0.0
        }, completion: { (finished) -> Void in
            self.removeFromSuperview()
        })
    }
    
    
    // handle device orientation changes
    @objc func deviceOrientationDidChange(_ notification:Notification) {
        self.frame = self.screenBounds()
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.reLayout()
        }) { (finished) -> Void in
            
        }
    }
    
    
    //------Tools-------
    // 计算frame
    func screenBounds() -> CGRect {
        var screenWidth  = UIScreen.main.bounds.size.width
        var screenHeight = UIScreen.main.bounds.size.height
        // On iOS7, screen width and height doesn't automatically follow orientation
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 {
            let interfaceOrientation = UIApplication.shared.statusBarOrientation
            if UIInterfaceOrientationIsLandscape(interfaceOrientation) {
                let tmp = screenWidth
                screenWidth = screenHeight
                screenHeight = tmp
            }
        }
        
        return CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
    }
    
    // 计算字符串高度
    func heighOfRow(_ text:NSString, font:CGFloat, width:CGFloat) -> CGFloat {
        let wSize:CGSize = text.boundingRect(with: CGSize(width: width, height: 0),
                                             options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                             attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: font)], context: nil).size
        
        return wSize.height;
    }
    
    
    
    
}

