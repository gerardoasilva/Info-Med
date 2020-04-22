//
//  Message.swift
//  Info-Med
//
//  Created by user168593 on 4/21/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class Message: NSObject {
    var text : String!
    var sender : String!
    
    init(sender : String, text : String){
        self.text = text
        self.sender = sender
    }
}
