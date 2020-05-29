//
//  PasswordViewController.swift
//  Info-Med
//
//  Created by user168608 on 5/29/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit
import FirebaseAuth

class PasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfCurrentPassword: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap recognizer in current view to hide keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Texfield Delegates
        tfCurrentPassword.delegate = self
        tfNewPassword.delegate = self
        tfConfirmPassword.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    // Allows navigation throguh textfields when "return" is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfCurrentPassword:
            tfNewPassword.becomeFirstResponder()
        case tfNewPassword:
            tfConfirmPassword.becomeFirstResponder()
        case tfConfirmPassword:
            pressSaveChanges(saveButton)
        default:
            textField.resignFirstResponder()

        }
        return true
    }
    
    
    func validateFields() -> String? {
        // Check if textfields are filled
        if tfCurrentPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            tfNewPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            tfConfirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Por favor llene todos los campos requeridos."
        }
        
        // Check if new password format is valid
        let cleanedNewPassword = tfNewPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedConfirmPassword = tfConfirmPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedNewPassword) == false {
            // Password is not valid
            return "La contraseña debe contener al menos 8 caracteres incluyendo una letra y un caracter especial."
        }

        // Check if passwords are the same
        if cleanedNewPassword != cleanedConfirmPassword {
            return "La contraseña nueva no coincide."
        }
    
        return nil
   }

    
    // Hides keyboard when user taps away from keyboard
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func pressSaveChanges(_ sender: UIButton) {
    let error = validateFields()

        if error != nil {
            // There was somwthing wrong with the textfields
            print(error!)
            //showError()
        }

        else {
            // Current information of user
            let user = Auth.auth().currentUser
            let currentPassword = tfCurrentPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = (user?.email)!

            // Set credential with current info of user
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

            // Reauthenticate user with credential
            user?.reauthenticate(with: credential, completion: { (result, error) in
                if let err = error {
                    print(err)
                } else{
                    // Set new password
                    let newPassword = self.tfNewPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    user?.updatePassword(to: newPassword) { (error) in
                        if let err = error {
                            print(err)
                        } else {
                            // Go to profile VC
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            })
        }
    }
    
    
    // function to return to previous VC
    @IBAction func pressCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
