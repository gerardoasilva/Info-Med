//
//  BubbleOfBubbles.swift
//  Info-Med
//
//  Created by user168593 on 5/25/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

///A bubble made out of several Option bubbles as to group their behabiour together
class BubbleOfBubbles: Bubble, OptionBubbleDeactivateProtocol {
    
    

    var subBubbles : [OptionBubble]!
    var acumulatedHeight = 0;
    var maxWidth = CGFloat(0);
    
    
    init(view: UIView, subB : [OptionBubble], send : String) {
        super.init(view: view, msg: Message(text: "", sender: send))
        self.backgroundColor = .clear
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 0
        
        self.subBubbles = subB
        
        addBubbles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //adds the reicived bubbles to the view as subViews in their correct positions
    func addBubbles(){
        //reset of dimensions
        var acumulatedHeight = 0;
        var maxWidth = CGFloat(0);
        
        let len = subBubbles.count
        
        for i in 0..<len{
            
            var addedHeight = 0
            if i == len - 1{
                addedHeight = Int(subBubbles[i].frame.height)
            }else{
                addedHeight = Int(subBubbles[i].frame.height) + subBubbles[i].padd
            }
            
            //get the biggest width out of all the subBubbles
            let bWidth = subBubbles[i].frame.width + subBubbles[i].layer.borderWidth * 4 + CGFloat(subBubbles[i].padd * 4)
            
            if  bWidth > maxWidth{
                maxWidth = bWidth
            }
            
            subBubbles[i].setY(y: CGFloat(acumulatedHeight))
            acumulatedHeight += addedHeight
            
            //set deactivation delegate as self so that this can deactivate all the bubbles
            subBubbles[i].deactivationDelegate = self
            
            self.addSubview(subBubbles[i])
        }
        
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: maxWidth, height: CGFloat(acumulatedHeight))
    }
    
    // MARK: - OptionBubble protocol implementation
    
    func blockFurtherActions(bbl: OptionBubble) {
        for b in subBubbles{
            b.pressed = true
            b.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0.8470588235, blue: 0.8588235294, alpha: 1)
            
            
            //code for removing remaining options, and only show the selected one
            /*
            for view in self.subviews{
                view.removeFromSuperview()
            }
        
            subBubbles = [bbl]
            addBubbles()*/
        }
    }
}
