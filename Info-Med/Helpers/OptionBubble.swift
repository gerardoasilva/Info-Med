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

class OptionBubble: Bubble {
    
    var bubbleDelegate: OptionBubbleActionProtocol?
    
    init(view: UIView, msg: Message, del: OptionBubbleActionProtocol) {
        
        msg.text = "     \(msg.text ?? "NIL")"
        
        super.init(view: view, msg: msg)
        
        bubbleDelegate = del
        
        //moves text to the right to make space for the button
        //self.textContainerInset = UIEdgeInsets(top: 10, left: 60, bottom: 10, right: 10)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        print("Option Tap")
        bubbleDelegate?.onOptionBubblePress(text: msg.text)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
