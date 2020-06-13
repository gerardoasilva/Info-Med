//
//  Bubble.swift
//  Info-Med
//
//  Created by user168593 on 4/21/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

// Class bubble that containts message and is displayed in the chat
class Bubble: UITextView {
    
    var msg: Message!
    var padd = 10
    var leftPadd = 50
    var senderIcon: UIImageView!
    var parentView: UIView!
    
    // Initializer function
    init(view: UIView, msg: Message) {
        // Declaration and initialization of variables
        let initX = CGFloat(padd)
        let initY = CGFloat(padd)
        let initW = view.frame.width
        let initH = CGFloat(40)
        
        // Create rectangle with initial dimensions
        let dimensions = CGRect(x: initX, y: initY, width: initW, height: initH)
        
        super.init(frame: dimensions, textContainer: nil) // Intialize the UITextView to such dimensions
        initialize() // Setup style of bubble
        
        // Set content
        self.msg = msg
        self.text = msg.text
        self.parentView = view
        
        //------------------------------------------
        
        adjustHeight()
        
        var limit = (view.frame.width / 5) * 4 // The proportion at wich the bubble truncates
        
        // Add bot image to bubble and set special width
        if msg.sender == "agent"{
            limit = (view.frame.width / 6) * 4
            senderIcon = UIImageView(image: UIImage(named: "bot"))
        }
        
        var x = initX
        var newW = frame.width // New width
        
        if msg.sender == "user"{
            self.backgroundColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 0.8470588235)
            self.textColor = UIColor.white
            
            
            if frame.width > limit - CGFloat(padd) { // If the width of the bubble after adjusting is bigger than the limit of 4/5 of the width of the screen + padding
                x = CGFloat(view.frame.width - limit)
                newW = CGFloat(limit - CGFloat(padd))
            }else{
                x = view.frame.width - CGFloat(padd) - frame.width
            }
        }
        else if msg.sender == "agent"{
            self.backgroundColor = .white
            self.textColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
            self.layer.borderWidth = 1.0
            self.layer.borderColor = #colorLiteral(red: 0.8352941176, green: 0.8470588235, blue: 0.8588235294, alpha: 1)
            
            if frame.width > limit - CGFloat(padd) { // If the width of the bubble after adjusting is bigger than the limit of 5/6 of the width of the screen + padding
                newW = CGFloat(limit - CGFloat(padd))
            }
            
            x += CGFloat(leftPadd)
        }else{
            self.backgroundColor = .white
            self.textColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
            self.layer.borderWidth = 1.0
            self.layer.borderColor = #colorLiteral(red: 0.8352941176, green: 0.8470588235, blue: 0.8588235294, alpha: 1)
            
            if frame.width > limit - CGFloat(padd) {//if the width of the bubble after adjusting is bigger than the limit of 5/6 of the width of the screen + padding
                newW = CGFloat(limit - CGFloat(padd))
            }
        }
        
        self.frame = CGRect(x: x, y: frame.origin.y, width: newW , height: frame.height)
        //set bubble height to content (text) size
        self.frame = CGRect(x: x, y: frame.origin.y, width: newW , height: self.contentSize.height)
        self.isScrollEnabled = false
        
        resetIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // Initializes only basic style
    func initialize(){
        // Set the background
        self.backgroundColor = .lightGray
        // Round the corners.
        self.layer.masksToBounds = true
        // Set the size of the roundness.
        self.layer.cornerRadius = 20.0
        // Set the thickness of the border.
        self.layer.borderWidth = 0
        // Set font
        self.font = UIFont(name: "Helvetica Neue", size: 18)
        // Set font color.
        self.textColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        // Set left justified.
        self.textAlignment = NSTextAlignment.left
        // Automatically detect links, dates, etc. and convert them to links.
        self.dataDetectorTypes = UIDataDetectorTypes.all
        // Set shadow darkness.
        self.layer.shadowOpacity = 0.0
        // Make text uneditable.
        self.isEditable = false
        //set border inset
        self.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    // Function that adjusts height of bubble
    func adjustHeight(){
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
    }
    
    func resetIcon(){
        
        if(msg.sender == "agent"){
            
            senderIcon.removeFromSuperview()
            let size = CGFloat(leftPadd-6)
            senderIcon.frame = CGRect(
                x: frame.origin.x - CGFloat(leftPadd),
                y: frame.origin.y + frame.height - size,
                width: size,
                height: size)
            parentView.addSubview(senderIcon)
        }
    }
    
    func deleteIcon(){
        if(msg.sender == "agent"){
            senderIcon.removeFromSuperview()
        }
    }
    
    func setY(y: CGFloat){
        self.frame = CGRect(x: frame.origin.x, y: y, width: frame.width , height: frame.height)
        resetIcon()
    }
}
