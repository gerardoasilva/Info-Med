//
//  PasswordViewController.swift
//  Info-Med
//
//  Created by user168608 on 5/28/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit
import FirebaseAuth

class PasswordViewController: UIViewController {
    
    @IBOutlet weak var tfCurrentPassword: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    
    
    @IBAction func pressSaveChanges(_ sender: UIButton) {
        let error = validateFields()

        if error != nil {
            // There was somwthing wrong with the textfields
            print(error)
            //showError()
        }

        else {
            // Current information of user
            let user = Auth.auth().currentUser
            let currentPassword = tfCurrentPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = (user?.email)!

            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

            user?.reauthenticate(with: credential, completion: { (result, error) in
                if let err = error {
                    print(err)
                } else{
                    let newPassword = self.tfNewPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    user?.updatePassword(to: newPassword) { (error) in
                        if let err = error {
                            print(err)
                        } else {
                            print("Success")
                            self.navigationController?.popViewController(animated: true)
                            // Go back to menu or profile?
                        }
                    }
                }
            })
        }
    }
    
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
