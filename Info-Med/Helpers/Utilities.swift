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
    
    // Validate if password has correct format
    static func isPasswordValid(_ password: String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")// modify this REGEX to make password friendlier
        return passwordTest.evaluate(with: password)
    }
    
    // Validate if phone number has correct format
    static func isPhoneNumberValid(_ phoneNumber: String) -> Bool {
        
        let phoneNumberTest = NSPredicate(format: "SELF MATCHES %@", "[0-9]{6,14}")
        
        return phoneNumberTest.evaluate(with: phoneNumber)
    }

}
