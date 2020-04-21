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

class RegisterViewController: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Check the fields and validate. If everything is correct, return nil. Otherwise, return the error message.
    func validateFields() -> String? {
        
        // Check that all the fields are filled in
        if tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            tfPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Por favor llene los campos requeridos."
        }
        
        // Check if email is valid
        let cleanedEmail = tfEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isEmailValid(cleanedEmail) == false {
            // Email is not valid
            return "Correo electrónico inválido."
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
            let firstName = tfFirstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = tfLastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = tfEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let phoneNumber = tfPhoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //Create user
            Auth.auth().createUser(withEmail: email, password: phoneNumber) { (result, err) in
                
                // Check for errors
                if err != nil {
                    
                    // There was an error creating the user
                    self.showError("Error creando usuario.")
                }
                else {
                    
                    // User was created successfully, now store first name and last name
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: [
                        "firstName":firstName,
                        "lastName":lastName,
                        "uid":result!.user.uid
                    ]) { (error) in
                        if error != nil {
                            // Show error message
                            self.showError("Error almacenando datos de usuario.")
                        }
                    }
                    
                    // Transition to the home screen
                    self.transitionToHome()
                }
            }
            
            
        }
    }
    
    func showError(_ message:String) {
        lbError.text = message
        lbError.alpha = 1
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
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
