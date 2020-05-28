//
//  LoginViewController.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 21/04/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    
    private var counter = 0
    private var viewOriginalFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Textfield delegates
        tfEmail.delegate = self
        tfPassword.delegate = self
        
        // Get the original frame of the ViewController
        viewOriginalFrame = self.view.frame
        
        // Setup navBar and All the elements for login
        configureNavbar()
        setUpElements()
        
        // Adds tap gesture recognizer in current view to hide keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Check if textfield has been edited to enable or not the login button
        setupAddTargetIsNotEmptyTextFields()
        
        // Register to listen keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - AUTHENTICATION
    
    // Verify user authentication when view appears to login automatically
    override func viewWillAppear(_ animated: Bool) {
        // Check user's authentication status
        Auth.auth().addStateDidChangeListener { (auth, user) in
            // If user is logged in go to ChatViewController
            if user != nil {
                self.transitionToChatVC()
            }
            else {
                print("Login needed\n")
            }
        }
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
            let phoneNumber = tfPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
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
    
    // Check the fields and validate. If everything is correct, return nil. Otherwise, return the error message.
    func validateFields() -> String? {
        
        // Check that all the fields are filled in
        if tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            tfPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Por favor llene todos los campos."
        }
        
        return nil
    }
    
    // Display error message in lbError
    func showError(_ message:String) {
        lbError.text = message
        lbError.alpha = 1
    }
    
    //MARK: - SETUP
    
    // Setup textfields to listen to edit changes
    func setupAddTargetIsNotEmptyTextFields() {
        loginButton.isEnabled = false
        tfEmail.addTarget(self, action: #selector(textFieldIsNotEmpty),
                          for: .editingChanged)
        tfPassword.addTarget(self, action: #selector(textFieldIsNotEmpty),
                             for: .editingChanged)
    }
    
    // Hides keyboard when user taps away from keyboard
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    func configureNavbar() {
        // Make navbar transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func setUpElements() {
        
        let screenHeight = self.view.bounds.height
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        tfEmail.translatesAutoresizingMaskIntoConstraints = false
        tfPassword.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        lbError.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints
        topView.backgroundColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 1)
        topView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        //        topView.heightAnchor.constraint(equalToConstant: screenHeight / 3).isActive = true
        topView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/3).isActive = true
        topView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        topView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        tfEmail.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: (screenHeight - topView.frame.height)/9).isActive = true
        tfEmail.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        //        tfEmail.widthAnchor.constraint(equalToConstant: screenWhidth / 6 * 5).isActive = true
        tfEmail.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 5/6).isActive = true
        tfEmail.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        lbError.textColor = #colorLiteral(red: 0.8588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        lbError.textAlignment = .center
        lbError.bottomAnchor.constraint(equalTo: tfEmail.topAnchor, constant: -5).isActive = true
        lbError.centerXAnchor.constraint(equalTo: tfEmail.centerXAnchor).isActive = true
        lbError.widthAnchor.constraint(equalTo: tfEmail.widthAnchor).isActive = true
        lbError.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        tfPassword.topAnchor.constraint(equalTo: tfEmail.bottomAnchor, constant: 25).isActive = true
        tfPassword.centerXAnchor.constraint(equalTo: tfEmail.centerXAnchor).isActive = true
        //        tfPassword.widthAnchor.constraint(equalToConstant: screenWhidth / 6 * 5).isActive = true
        tfPassword.widthAnchor.constraint(equalTo: tfEmail.widthAnchor).isActive = true
        tfPassword.heightAnchor.constraint(equalTo: tfEmail.heightAnchor).isActive = true
        
        loginButton.topAnchor.constraint(equalTo: tfPassword.bottomAnchor, constant: 25).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: tfPassword.centerXAnchor).isActive = true
        //        loginButton.widthAnchor.constraint(equalToConstant: screenWhidth / 6 * 3).isActive = true
        loginButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/2).isActive = true
        loginButton.heightAnchor.constraint(equalTo: tfEmail.heightAnchor).isActive = true
        
        registerButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 12)
        registerButton.tintColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        //        registerButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        registerButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/13).isActive = true
        registerButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        registerButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.widthAnchor.constraint(equalTo: tfEmail.widthAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: registerButton.topAnchor).isActive = true
        separatorView.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        
        
        
        // Hide error label
        lbError.alpha = 0
        
        // Style elements
        Utilities.styleTextField(tfEmail)
        Utilities.styleTextField(tfPassword)
        Utilities.styleFilledButton(loginButton)
        
    }
    
    // MARK: - TEXTFIELDS
    
    // Allows navigation through textfields when "return" is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            textField.resignFirstResponder()
            tfPassword.becomeFirstResponder()
        }
        else if textField == tfPassword {
            textField.resignFirstResponder()
            loginTapped(loginButton)
        }
        return true
    }
    
    // Function that makes sure there is content in textfields to enable login button
    @objc func textFieldIsNotEmpty(sender: UITextField) {
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let email = tfEmail.text, !email.isEmpty,
            let password = tfPassword.text, !password.isEmpty
            
            else
        {
            self.loginButton.isEnabled = false
            return
        }
        // Enable login button if all conditions are met
        loginButton.isEnabled = true
        //        loginButton.setTitleColor(.white, for: .normal)
    }
    
    // MARK: - NAVIGATION
    
    func transitionToChatVC() {
        let chatViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.chatViewController) as? ChatViewController
        //adds a nav controler to the newly instantiated view so that the side menu is visible
        let navController = UINavigationController(rootViewController: chatViewController!)
        
        view.window?.rootViewController = navController
        view.window?.makeKeyAndVisible()
    }
    
    // MARK: - KEYBOARD HANDLERS
    
    // Move the view up when keybord shows
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, self.view.frame.height == self.viewOriginalFrame.height {
            
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let screenHeight = self.view.bounds.height - keyboardSize.height
            
            UIView.animate(withDuration: duration) {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: screenHeight)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // Return the view to its original position when keyboard hides
    @objc func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let screenHeight = self.viewOriginalFrame.height
        
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: screenHeight)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
}
