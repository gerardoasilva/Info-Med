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
    let padd = 20
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    init(view: UIView, msg: Message) {
        let initX = CGFloat(padd)
        let initY = CGFloat(padd)
        let initW = view.frame.width - CGFloat(padd * 2)
        let initH = CGFloat(100)
                
        let dimensions = CGRect(x: initX, y: initY, width: initW, height: initH)
        super.init(frame: dimensions, textContainer: nil)
        initialize()
        
        self.msg = msg
        self.text = msg.text
        
        adjustHeight()
        
        let limit = (view.frame.width / 5) * 4
        var x = initX
        var newW = frame.width
        
        if msg.sender == "user"{
            self.backgroundColor = .darkGray
            self.textColor = UIColor.white
            
            if frame.width > limit - CGFloat(padd) {//if the width of the bubble after adjusting is bigger than the limit of 4/5 of the width of the screen + padding
                x = CGFloat(view.frame.width - limit)
                newW = CGFloat(limit - CGFloat(padd))
            }else{
                x = view.frame.width - CGFloat(padd) - frame.width
            }
        }else{
            self.backgroundColor = .lightGray
            self.textColor = UIColor.black
            
            if frame.width > limit - CGFloat(padd) {//if the width of the bubble after adjusting is bigger than the limit of 5/6 of the width of the screen + padding
                newW = CGFloat(limit - CGFloat(padd))
            }
        }
        self.frame = CGRect(x: x, y: frame.origin.y, width: newW , height: frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize(){
        // Set the background
        self.backgroundColor = .lightGray
        // Round the corners.
        self.layer.masksToBounds = true
        // Set the size of the roundness.
        self.layer.cornerRadius = 14.0
        // Set the thickness of the border.
        self.layer.borderWidth = 0
        // Set the border color to black.
        //textView.layer.borderColor = UIColor.black.cgColor
        // Set the font.
        self.font = UIFont.systemFont(ofSize: 18.0)
        // Set font color.
        self.textColor = UIColor.black
        // Set left justified.
        self.textAlignment = NSTextAlignment.left
        // Automatically detect links, dates, etc. and convert them to links.
        self.dataDetectorTypes = UIDataDetectorTypes.all
        // Set shadow darkness.
        self.layer.shadowOpacity = 0.5
        // Make text uneditable.
        self.isEditable = false
    }
    
    func adjustHeight(){
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
        self.isScrollEnabled = false
    }
    
    func setY(y: CGFloat){
        self.frame = CGRect(x: frame.origin.x, y: y, width: frame.width , height: frame.height)
    }
}
