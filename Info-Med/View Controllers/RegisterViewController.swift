//
//  RegisterViewController.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 21/04/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = true
        
        // Adds tap recognizer in current view to hide keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Textfield delegates
        tfEmail.delegate = self
        tfPassword.delegate = self
        tfPhoneNumber.delegate = self
        tfFirstName.delegate = self
        tfLastName.delegate = self
        
    }
    
    // Hides keyboard when user taps away from keyboard
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Allows navigation through textfields when "return" is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfEmail:
            tfPassword.becomeFirstResponder()
        case tfPassword:
            tfPhoneNumber.becomeFirstResponder()
        case tfPhoneNumber:
            tfFirstName.becomeFirstResponder()
        case tfFirstName:
            tfLastName.becomeFirstResponder()
        case tfLastName:
            registerTapped(registerButton)
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }

    
    // Check the fields and validate. If everything is correct, return nil. Otherwise, return the error message.
    func validateFields() -> String? {
        
        // Check that all the fields are filled in
        if tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        tfPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || tfPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Por favor llene todos los campos requeridos."
        }
        
        // Check if email is valid
        let cleanedEmail = tfEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isEmailValid(cleanedEmail) == false {
            // Email is not valid
            return "Correo electrónico inválido."
        }
        
        // Check if password is valid
        let cleanedPassword = tfPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password is not valid
            return "La contraseña debe contener al menos 8 caracteres incluyendo una letra y un caracter especial."
        }
        
        // Check if phoneNumber is valid
        let cleanedPhoneNumber = tfPhoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPhoneNumberValid(cleanedPhoneNumber) == false {
            // Phone number is not valid
            return "Teléfono inválido."
        }
    
        return nil
    }
    
    // Authenticate user and grant access
    @IBAction func registerTapped(_ sender: UIButton) {
        // Validate fields
        let error = validateFields()
        
        if error != nil {
            // Theres something wrong with fields, show error message
            showError(error!)
        }
        else {
            
            // Create cleaned versions of the data
            let email = tfEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = tfPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let phoneNumber = tfPhoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let firstName = tfFirstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = tfLastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            //Create user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    print(err!.localizedDescription)
                    // There was an error creating the user
                    self.showError("Correo electrónico o teléfono inválido.")
                }
                else {
                    
                    // User was created successfully, now store first name and last name
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: [
                        "uid":result!.user.uid,
                        "phoneNumber":phoneNumber,
                        "firstName":firstName,
                        "lastName":lastName
                    ]) { (error) in
                        if error != nil {
                            // Show error message
                            self.showError("Hubo un error almacenando los datos de usuario.")
                        }
                    }
                    
                    // Transition to the home screen
                    self.transitionToChatVC()
                }
            }
            
        }
    }
    
    // Display error message in the form
    func showError(_ message:String) {
        lbError.text = message
        lbError.alpha = 1
    }
    
    // Transitions view to chat
    func transitionToChatVC() {
        let chatViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.chatViewController) as? ChatViewController
        let navController = UINavigationController(rootViewController: chatViewController!)
        
        view.window?.rootViewController = navController
        //view.window?.rootViewController = chatViewController
        view.window?.makeKeyAndVisible()
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
