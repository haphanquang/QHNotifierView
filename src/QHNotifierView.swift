//
//  QHNotifierView.swift
//  Phone
//
//  Created by Phan Quang ha on 12/25/15.
//  Copyright © 2015 hoiio. All rights reserved.
//

import Foundation
import UIKit

public class QHNotifierView: UIView {
    //animate and show
    public class func show(message msg: String) {
        let window = UIApplication.sharedApplication().keyWindow
        if let _ = window {
            QHNotifierView.showIn(window: window!, msg: msg)
        }
    }
    public class func show(message msg: String, autoHide: Bool) {
        let window = UIApplication.sharedApplication().keyWindow
        if let _ = window {
            QHNotifierView.showIn(window: window!, msg: msg)
        }
        if autoHide {
            QHNotifierView.hide(after: 1.2)
        }
    }
    
    public class func setBgColor(color: UIColor) {
        QHNotifierView.defaultNotifierView.bgColor = color
    }
    public class func setTextColor(color: UIColor){
        QHNotifierView.defaultNotifierView.textColor = color
    }
    
    public class func hide() {
        let notifier = QHNotifierView.defaultNotifierView
        notifier.hideMe()
    }
    public class func hide(after second: Double) {
        let notifier = QHNotifierView.defaultNotifierView
        if notifier.isShowing {
            notifier.hideMeAfter(second)
        }
        
    }
    
    private class func showIn(window window: UIWindow, msg: String) {
        let notifier = QHNotifierView.defaultNotifierView
        notifier.message = msg
        notifier.inWindow = window
        notifier.showMe()
    }
    
    private var inWindow: UIWindow? {
        didSet {
            reloadSize()
        }
    }
    private let textLabel: UILabel = UILabel()
    
    private var bgColor: UIColor = UIColor.redColor(){
        didSet {
            backgroundColor = bgColor
        }
    }
    private var textColor: UIColor = UIColor.whiteColor(){
        didSet {
            textLabel.textColor = textColor
        }
    }
    
    private var message: String? {
        didSet {
            textLabel.text = message
            reloadSize()
        }
    }
    
    private var horizontalPadding: CGFloat = 10.0{
        didSet {
            hor1Constraint?.constant = horizontalPadding
            hor2Constraint?.constant = horizontalPadding
            reloadSize()
        }
    }
    private var verticalPadding: CGFloat = 3.0 {
        didSet {
            
            var statusBarHeight: CGFloat = 20.0
            if UIApplication.sharedApplication().statusBarHidden {
                statusBarHeight = 0.0
            }
            
            ver1Constraint?.constant = verticalPadding + statusBarHeight
            ver2Constraint?.constant = verticalPadding
            reloadSize()
        }
    }
    
    private var ver1Constraint: NSLayoutConstraint?
    private var ver2Constraint: NSLayoutConstraint?
    private var hor1Constraint: NSLayoutConstraint?
    private var hor2Constraint: NSLayoutConstraint?
    
    private var isShowing: Bool = false
    private var canHide: Bool = false
    
    
    static let defaultNotifierView = QHNotifierView(frame: CGRectZero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel.font = UIFont.systemFontOfSize(13)
        textLabel.textColor = UIColor.whiteColor()
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .ByWordWrapping
        self.backgroundColor = UIColor.redColor()
        
        addSubview(textLabel)
        setupConstraints()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        textLabel.font = UIFont.systemFontOfSize(13)
        textLabel.textColor = UIColor.whiteColor()
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.lineBreakMode = .ByWordWrapping
        self.backgroundColor = UIColor.redColor()
        
        addSubview(textLabel)
        setupConstraints()
    }
    
    private func reloadSize () {
        if inWindow == nil {
            inWindow = UIApplication.sharedApplication().keyWindow
        }
        
        let width = inWindow!.bounds.size.width
        let sz = message?.qhTextSize(textLabel.font, width: width)
        
        if let _ = sz {
            
            var statusBarHeight: CGFloat = 20.0
            if UIApplication.sharedApplication().statusBarHidden {
                statusBarHeight = 0.0
            }
            
            let height = sz!.height + statusBarHeight + 2 * verticalPadding + 10
            
            bounds.size = CGSizeMake(width, height)
            self.frame.origin = CGPointMake(0, -height)
        }
        layoutSubviews()
    }
    
    private func setupConstraints () {
        
        var statusBarHeight: CGFloat = 20.0
        if UIApplication.sharedApplication().statusBarHidden {
            statusBarHeight = 0.0
        }
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["label":textLabel]
        let metrics = ["hp":horizontalPadding, "vp":verticalPadding, "topvp":verticalPadding + statusBarHeight]
        
        let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-topvp-[label]-vp-|", options:[] , metrics: metrics, views: views)
        
        //cheat
        ver1Constraint = vConstraint[0]
        ver2Constraint = vConstraint[1]
        
        let hConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-hp-[label]-hp-|", options: [], metrics: metrics, views: views)
        
        //cheat
        hor1Constraint = hConstraint[0]
        hor2Constraint = hConstraint[1]
        
        addConstraints(vConstraint)
        addConstraints(hConstraint)
    }
}

extension QHNotifierView {
    //Todo: Double
    private func showMe () {
        if !isShowing {
            isShowing = true
            canHide = true
            if inWindow == nil {
                inWindow = UIApplication.sharedApplication().keyWindow
            }
            inWindow!.addSubview(self)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {[unowned self] in
                
                var frr = self.inWindow!.frame
                let size = self.frame.size
                frr.origin.y = size.height
                self.inWindow!.frame = frr
                
            }, completion: nil)
        }
        
    }
    private func hideMe () {
        hideMeAfter(0.0)
    }
    private func hideMeAfter(time: Double) {
        if canHide {
            canHide = false
            if let _ = inWindow {
                UIView.animateWithDuration(0.5, delay: time, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {[unowned self] in
                    
                    var frr = self.inWindow!.frame
                    frr.origin.y = 0
                    self.inWindow!.frame = frr
                    
                    }, completion: { [unowned self] completed in
                        self.removeFromSuperview()
                        self.inWindow = nil
                        self.isShowing = false
                    })
            }
        }
    }
}

extension String {
    func qhTextSize(font: UIFont, width: CGFloat) -> CGSize {
        let calString = NSString(string: self)
        let textSize = calString.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: [NSFontAttributeName: font], context: nil)
        return textSize.size
    }
}