//
//  Bubble.swift
//  Info-Med
//
//  Created by user168593 on 4/21/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class Bubble: UITextView {
    
    var msg: Message!
    let padd = 10

    init(view: UIView, msg: Message) {
        //
        let initX = CGFloat(padd)
        let initY = CGFloat(padd)
        let initW = view.frame.width
        let initH = CGFloat(40)
                
        let dimensions = CGRect(x: initX, y: initY, width: initW, height: initH)
        
        super.init(frame: dimensions, textContainer: nil)//intialize the UITextView to such dimensions
        initialize()
        
        self.msg = msg
        self.text = msg.text
        
        //------------------------------------------
        
        adjustHeight()
        
        let limit = (view.frame.width / 5) * 4 //the proportion at wich the bubble truncates
        var x = initX
        var newW = frame.width //new width
        
        if msg.sender == "user"{
            self.backgroundColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 0.8470588235)
            self.textColor = UIColor.white
            
            
            if frame.width > limit - CGFloat(padd) {//if the width of the bubble after adjusting is bigger than the limit of 4/5 of the width of the screen + padding
                x = CGFloat(view.frame.width - limit)
                newW = CGFloat(limit - CGFloat(padd))
            }else{
                x = view.frame.width - CGFloat(padd) - frame.width
            }
        }
        else {
            self.backgroundColor = .white
            self.textColor = .black
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    //initializes only basic visual stuff
    func initialize(){
        // Set the background
        self.backgroundColor = .lightGray
        // Round the corners.
        self.layer.masksToBounds = true
        // Set the size of the roundness.
        self.layer.cornerRadius = 20.0
        // Set the thickness of the border.
        self.layer.borderWidth = 0
        // Set the font.
        self.font = UIFont.preferredFont(forTextStyle: .body)
        self.adjustsFontForContentSizeCategory = true
        // Set font color.
        self.textColor = UIColor.black
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
    
    func adjustHeight(){
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
        //self.isScrollEnabled = false
    }
    
    func setY(y: CGFloat){
        self.frame = CGRect(x: frame.origin.x, y: y, width: frame.width , height: frame.height)
    }
}
