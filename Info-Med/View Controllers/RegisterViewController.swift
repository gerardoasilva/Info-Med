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
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Elements setup
        configureNavbar()
        setUpElements()
        setupAddTargetIsNotEmptyTextFields()
        
        // Adds tap recognizer in current view to hide keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Textfield delegates
        tfEmail.delegate = self
        tfPassword.delegate = self
        tfPhoneNumber.delegate = self
        tfFirstName.delegate = self
        tfLastName.delegate = self
        
        // Gesture recognizer to go back sliding the edge of the screen to the right
        let leftEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popViewController))
        leftEdgePan.edges = .left
        view.addGestureRecognizer(leftEdgePan)
        
    }
    
    // MARK: - SETUP
    
    // Add constraints and style
    func setUpElements() {
        
        let screenWhidth = self.view.bounds.width
        
        lbError.translatesAutoresizingMaskIntoConstraints = false
        tfEmail.translatesAutoresizingMaskIntoConstraints = false
        tfPassword.translatesAutoresizingMaskIntoConstraints = false
        tfPhoneNumber.translatesAutoresizingMaskIntoConstraints = false
        tfFirstName.translatesAutoresizingMaskIntoConstraints = false
        tfLastName.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        lbError.textColor =  #colorLiteral(red: 0.8588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        lbError.numberOfLines = 3
        lbError.textAlignment = .center
        lbError.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: -15).isActive = true
        lbError.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        lbError.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 5/6).isActive = true
        lbError.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Add constraints
        tfEmail.topAnchor.constraint(equalTo: lbError.bottomAnchor, constant: 5).isActive = true
        tfEmail.widthAnchor.constraint(equalToConstant: screenWhidth / 6 * 5).isActive = true
        tfEmail.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tfEmail.centerXAnchor.constraint(equalTo: lbError.centerXAnchor).isActive = true
        
        tfPassword.topAnchor.constraint(equalTo: tfEmail.bottomAnchor, constant: 25).isActive = true
        tfPassword.heightAnchor.constraint(equalToConstant: tfEmail.bounds.height).isActive = true
        tfPassword.widthAnchor.constraint(equalToConstant: screenWhidth / 6 * 5).isActive = true
        tfPassword.centerXAnchor.constraint(equalTo: tfEmail.centerXAnchor).isActive = true
        
        tfPhoneNumber.topAnchor.constraint(equalTo: tfPassword.bottomAnchor, constant: 25).isActive = true
        tfPhoneNumber.widthAnchor.constraint(equalToConstant: screenWhidth / 6 * 5).isActive = true
        tfPhoneNumber.heightAnchor.constraint(equalToConstant: tfPassword.bounds.height).isActive = true
        tfPhoneNumber.centerXAnchor.constraint(equalTo: tfPassword.centerXAnchor).isActive = true
        
        tfFirstName.topAnchor.constraint(equalTo: tfPhoneNumber.bottomAnchor, constant: 25).isActive = true
        tfFirstName.widthAnchor.constraint(equalToConstant: screenWhidth / 6 * 5).isActive = true
        tfFirstName.heightAnchor.constraint(equalToConstant: tfPhoneNumber.bounds.height).isActive = true
        tfFirstName.centerXAnchor.constraint(equalTo: tfPhoneNumber.centerXAnchor).isActive = true
        
        tfLastName.topAnchor.constraint(equalTo: tfFirstName.bottomAnchor, constant: 25).isActive = true
        tfLastName.widthAnchor.constraint(equalToConstant: screenWhidth / 6 * 5).isActive = true
        tfLastName.heightAnchor.constraint(equalToConstant: tfFirstName.bounds.height).isActive = true
        tfLastName.centerXAnchor.constraint(equalTo: tfFirstName.centerXAnchor).isActive = true
        
        registerButton.topAnchor.constraint(equalTo: tfLastName.bottomAnchor, constant: 25).isActive = true
        registerButton.widthAnchor.constraint(equalToConstant: screenWhidth / 6 * 3).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: tfLastName.bounds.height).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: tfLastName.centerXAnchor).isActive = true
        
        loginButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 12)
        loginButton.tintColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        loginButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        loginButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/13).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        separatorView.bottomAnchor.constraint(equalTo: loginButton.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalToConstant: screenWhidth / 6 * 5).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
        
        // Hide error label
        lbError.alpha = 0
        
        // Style elements
        Utilities.styleTextField(tfEmail)
        Utilities.styleTextField(tfPassword)
        Utilities.styleTextField(tfPhoneNumber)
        Utilities.styleTextField(tfFirstName)
        Utilities.styleTextField(tfLastName)
        Utilities.styleFilledButton(registerButton)
        
    }
    
    // Setup textfields to listen to edit changes
    func setupAddTargetIsNotEmptyTextFields() {
        registerButton.isEnabled = false
        tfEmail.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        tfPassword.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        tfPhoneNumber.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
    }
    
    func configureNavbar() {
        // Make navbar transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - TEXTFIELD HANDLERS
    
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
            return "La contraseña debe ser de 8 o más caracteres con una mayúscula y un caracter especial."
        }
        
        // Check if phoneNumber is valid
        let cleanedPhoneNumber = tfPhoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPhoneNumberValid(cleanedPhoneNumber) == false {
            // Phone number is not valid
            return "Teléfono inválido."
        }
        
        return nil
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
    
    // Makes sure to enable register button only when required textflieds have content inside
    @objc func textFieldIsNotEmpty(sender: UITextField) {
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let email = tfEmail.text, !email.isEmpty,
            let password = tfPassword.text, !password.isEmpty,
            let phoneNum = tfPhoneNumber.text, !phoneNum.isEmpty
            else
        {
            self.registerButton.isEnabled = false
            return
        }
        // enable register button if all conditions are met
        registerButton.isEnabled = true
    }
    
    // MARK: - KEYBOARD
    
    // Hides keyboard when user taps away from keyboard
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - NAVIGATION
    @IBAction func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Transitions view to chat
    func transitionToChatVC() {
        let chatViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.chatViewController) as? ChatViewController
        //adds a nav controler to the newly instantiated view so that the side menu is visible
        let navController = UINavigationController(rootViewController: chatViewController!)
        
        view.window?.rootViewController = navController
        //view.window?.rootViewController = chatViewController
        view.window?.makeKeyAndVisible()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
    
    // Display error message in lbError
    func showError(_ message:String) {
        lbError.text = message
        lbError.alpha = 1
    }


}
