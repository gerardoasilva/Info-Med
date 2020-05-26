//
//  TypingBubble.swift
//  Info-Med
//
//  Created by user168593 on 5/25/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class TypingBubble: Bubble {
    init(view: UIView) {
        super.init(view: view, msg: Message(text: " ... ", sender: "Debug"))
        //self.font = UIFont.preferredFont(forTextStyle: .title1)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
