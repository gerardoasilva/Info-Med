//
//  Utilities.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 21/04/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import Foundation
import UIKit

class Utilities: NSObject {
    
    // Validate if email has correct format
    static func isEmailValid(_ email: String) -> Bool {
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        
        return emailTest.evaluate(with: email)
    }

}
