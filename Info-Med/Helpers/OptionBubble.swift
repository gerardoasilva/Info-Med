//
//  OptionBubble.swift
//  Info-Med
//
//  Created by user168593 on 5/25/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

protocol OptionBubbleActionProtocol {
    func onOptionBubblePress(text: String)
}

protocol OptionBubbleDeactivateProtocol {
    func blockFurtherActions(bbl: OptionBubble!)
}

class OptionBubble: Bubble {
    
    var bubbleDelegate: OptionBubbleActionProtocol?
    var deactivationDelegate : OptionBubbleDeactivateProtocol?
    
    var pressed : Bool = false
    
    // Initializer function
    init(view: UIView, msg: Message, sTxt: String, pd: Int ,del: OptionBubbleActionProtocol) {
        
        msg.text = "        \(msg.text ?? "NIL")"
        super.init(view: view, msg: msg)
        
        bubbleDelegate = del
        
        // Setup style
        padd = pd
        let smallView = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: self.frame.height))
        smallView.text = sTxt
        smallView.backgroundColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 0.8470588235)
        smallView.layer.masksToBounds = true
        smallView.layer.cornerRadius = 20.0
        smallView.layer.borderWidth = 1
        smallView.font = UIFont(name: "Helvetica Neue", size: 18)
        smallView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        smallView.layer.borderColor = #colorLiteral(red: 0.8352941176, green: 0.8470588235, blue: 0.8588235294, alpha: 1)
        smallView.textAlignment = NSTextAlignment.center
        
        self.addSubview(smallView)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Function that changes style of selected suggestion and blocks further interaction
    @objc func handleTap(sender: UITapGestureRecognizer){
        if !(pressed){
            bubbleDelegate?.onOptionBubblePress(text: msg.text)
            deactivationDelegate?.blockFurtherActions(bbl: self)
            self.backgroundColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 0.8470588235)
            self.textColor = .white
        }
    }
}
