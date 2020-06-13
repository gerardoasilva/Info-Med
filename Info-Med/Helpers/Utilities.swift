//
//  Utilities.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 21/04/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import Foundation
import UIKit

// This class contains static functions used to style elements inside the apllication or validate them
class Utilities: NSObject {
    
    // Function to style input text fields
    static func styleTextField(_ textField: UITextField) {
        
        // Remove border on textfield
        textField.textColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        textField.backgroundColor = .white
        textField.borderStyle = .none
        textField.layer.cornerRadius = textField.bounds.height / 2
        textField.textAlignment = .center
        textField.font = UIFont(name: "Helvetica Neue", size: 20)
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowRadius = 5
        textField.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
    }
    
    // Function to style password change textFields
    static func styleChangePasswordTextfield(_ textField: UITextField) {
        // Remove border on textfield
        textField.textColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        textField.backgroundColor = .white
        textField.borderStyle = .none
        textField.layer.cornerRadius = 3
        textField.textAlignment = .left
        textField.font = UIFont(name: "Helvetica Neue", size: 20)
        textField.layer.borderColor = #colorLiteral(red: 0.5990002751, green: 0.6184628606, blue: 0.6656202674, alpha: 1)
        textField.layer.borderWidth = 1
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
    }
    
    // Function to style buttons
    static func styleFilledButton(_ button: UIButton) {
        // Filled rounded corner style
        button.backgroundColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 1)
        button.layer.cornerRadius = button.frame.height / 2
        button.tintColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5), for: .disabled)
        button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20)
        button.titleLabel?.textColor = .white
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 10)
    }
    
    // Function to validate if email has correct format
    static func isEmailValid(_ email: String) -> Bool {
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        
        return emailTest.evaluate(with: email)
    }
    
    // Funtion to validate if password has correct format
    static func isPasswordValid(_ password: String) -> Bool {
        // Password has at least 8 characters
        if (password.count < 8) {
            return false
        }
        
        // Password has at least one digit
        if (password.range(of:  #"\d+"#, options: .regularExpression) == nil){
            return false
        }
        
        // Password has at least one upper case character
        let upperCaseTest = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
        
        return upperCaseTest.evaluate(with: password)
    }
    
    // Function to validate if phone number has correct format
    static func isPhoneNumberValid(_ phoneNumber: String) -> Bool {
        
        let phoneNumberTest = NSPredicate(format: "SELF MATCHES %@", "[0-9]{6,14}")
        
        return phoneNumberTest.evaluate(with: phoneNumber)
    }
    
}
