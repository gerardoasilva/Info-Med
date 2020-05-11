//
//  LoginViewController.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 21/04/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adds tap recognizer in current view to hide keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }
    
    // Hides keyboard when user taps away from keyboard
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Check the fields and validate. If everything is correct, return nil. Otherwise, return the error message.
    func validateFields() -> String? {
        
        // Check that all the fields are filled in
        if tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            tfPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Por favor llene todos los campos."
        }
    
        return nil
    }
    
    // Authenticate user and grant access
    @IBAction func loginTapped(_ sender: UIButton) {
        
        // Validate fields
        let error = validateFields()
        

        if error != nil {
            
            // There's something wrong with fields
            showError(error!)
        }
        else {
            
            // Create cleaned versions of text fields
            let email = tfEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let phoneNumber = tfPhoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines)
         
            // Signing in the user
            Auth.auth().signIn(withEmail: email, password: phoneNumber) { (result, error) in
                
                if error != nil {
                    
                    // There was an error signing in the user
                    self.showError("Correo electrónico o teléfono incorrecto.")
                }
                else {
                    
                    // User signed in successfully
                    self.transitionToChatVC()
                    
                }
            }
            
        }
    }
    
    func showError(_ message:String) {
        lbError.text = message
        lbError.alpha = 1
    }
    
    func transitionToChatVC() {
        let chatViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.chatViewController) as? ChatViewController
        
        view.window?.rootViewController = chatViewController
        view.window?.makeKeyAndVisible()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
