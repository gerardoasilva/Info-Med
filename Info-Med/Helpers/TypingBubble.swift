//
//  TypingBubble.swift
//  Info-Med
//
//  Created by user168593 on 5/25/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

// A bubble that shows agent is getting a response
class TypingBubble: Bubble {
    
    // Initializer function
    init(view: UIView) {
        super.init(view: view, msg: Message(text: " ... ", sender: "Debug"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
