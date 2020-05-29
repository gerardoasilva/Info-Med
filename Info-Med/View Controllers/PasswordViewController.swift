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
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cambiar contraseña"
        // Texfield Delegates
        tfCurrentPassword.delegate = self
        tfNewPassword.delegate = self
        tfConfirmPassword.delegate = self
        
        // Setup elements of the view controller
        setupElements()
        setupAddTargetIsNotEmptyTextFields()

        
        // Add tap recognizer in current view to hide keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Gesture recognizer to go back sliding the edge of the screen to the right
        let leftEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popViewController(_:)))
        leftEdgePan.edges = .left
        view.addGestureRecognizer(leftEdgePan)

    }
    
    // MARK: - SETUP
    func setupElements() {
        lbError.textColor = #colorLiteral(red: 0.8588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        lbError.numberOfLines = 3
        lbError.textAlignment = .center
        lbError.alpha = 0
//        lbError.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: -15).isActive = true
//        lbError.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        lbError.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 5/6).isActive = true
//        lbError.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Password button style
        // Filled rounded corner style
        saveButton.titleLabel?.text = "Cambiar"
        saveButton.backgroundColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 1)
        saveButton.layer.cornerRadius = saveButton.frame.height / 3
        saveButton.tintColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        saveButton.titleLabel?.textAlignment = .center
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5), for: .disabled)
        saveButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20)
        saveButton.titleLabel?.textColor = .white
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOpacity = 0.1
        saveButton.layer.shadowRadius = 5
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        // Cancel button style
        // Filled rounded corner style
        cancelButton.titleLabel?.text = "Cancelar"
        cancelButton.backgroundColor = #colorLiteral(red: 0.8588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        cancelButton.layer.cornerRadius = saveButton.frame.height / 3
        cancelButton.tintColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5), for: .disabled)
        cancelButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20)
        cancelButton.titleLabel?.textColor = .white
        cancelButton.layer.shadowColor = UIColor.black.cgColor
        cancelButton.layer.shadowOpacity = 0.1
        cancelButton.layer.shadowRadius = 5
        cancelButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        Utilities.styleChangePasswordTextfield(tfCurrentPassword)
        Utilities.styleChangePasswordTextfield(tfNewPassword)
        Utilities.styleChangePasswordTextfield(tfConfirmPassword)
    }
    
    // Setup textfields to listen to edit changes
       func setupAddTargetIsNotEmptyTextFields() {
           saveButton.isEnabled = false
           tfCurrentPassword.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
           tfNewPassword.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
           tfConfirmPassword.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
       }
    
    // Makes sure to enable register button only when required textflieds have content inside
       @objc func textFieldIsNotEmpty(sender: UITextField) {
           
           sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
           
           guard
               let currentPassword = tfCurrentPassword.text, !currentPassword.isEmpty,
               let newPassword = tfNewPassword.text, !newPassword.isEmpty,
               let confirmedPassword = tfConfirmPassword.text, !confirmedPassword.isEmpty
               else
           {
               self.saveButton.isEnabled = false
               return
           }
           // enable register button if all conditions are met
           saveButton.isEnabled = true
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
            showError(error!)
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
                    self.showError("La contraseña actual no es correcta.")
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
    @IBAction func popViewController(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Display error message in lbError
    func showError(_ message:String) {
        lbError.text = message
        lbError.alpha = 1
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
