//
//  ChatViewController.swift
//  Info-Med
//
//  Created by user168593 on 4/21/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
// something

import UIKit
import AVFoundation
import FirebaseAuth

public struct FAQ: Codable {
    var textInput: String
}

class ChatViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var messageScrollView: UIScrollView!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var btSend: UIButton!
    @IBOutlet var inputToolBar: UIToolbar!
    
    var menuController : UIViewController! //side menu view controller
    var shouldExpand = true //if the side menu is expanded or contracted
    let menuLimit = 130
    
    var activeField: UITextField!
    var bubblesList: [Bubble]!  //list of chat bubbles were new bubbles are pushed to
    
    var contexts: [Context] = [Context]() // Declare empty Context array to store contexts from queries
    
    var acumulatedHeight = 0    //the virtual height of the bubbles areas, gets extended as new bubbles are added
    var offsetAccum = 0 //the inner view offset, must correspond to the accumulated height
    var toolBarOriginalFrame = CGRect(x: 0, y: 0, width: 0, height: 0) //the original position of the toolbar
    
    /// This function displays a message bubble from agent in messageScrollView
    ///
    /// ```
    /// displayResponse("Bienvenido") // Displays bubble with "Bienvenido"
    /// ```
    /// - Parameter msg: The string to be displayed
    /// - Returns: Void
    func displayResponse(msg: String) {
        print("Request completed")
        addBubble(bbl: Bubble(view: messageScrollView, msg: Message(text: msg, sender: "agent")))
    }
    
    /// This function adds a bubble to array of Bubbles (bubbleList)
    ///
    /// ```
    /// addBubble(bbl: Bubble) // Displays bubble with Bubble attributes
    /// ```
    /// - Parameter bb1: The Bubble object to be added to the view
    /// - Returns: Void
    func addBubble(bbl: Bubble) {
        // Is the first bubble
        if bubblesList == nil{
            bubblesList = [bbl]
            acumulatedHeight += bbl.padd
            messageScrollView.contentSize.height = CGFloat(acumulatedHeight) //adds initial padd
        }
            // Not the first bubble
        else {
            bubblesList.append(bbl)
        }
        
        // Store the height added by bubble, plus spacing, in the view
        let addedHeight = Int(bbl.frame.height) + bbl.padd
        // Set position to bubble added
        bbl.setY(y: CGFloat(acumulatedHeight))
        // Update the accumulated height for later view scroll size update
        acumulatedHeight += addedHeight
        // Add view with bubble to scroll view
        messageScrollView.addSubview(bbl)
        // Update size of scroll view's content
        messageScrollView.contentSize.height = CGFloat(acumulatedHeight )
        
        // Check if content is larger than scroll view's actual height
        if CGFloat(messageScrollView.contentSize.height) >= messageScrollView.frame.height {
            // Add height to offset
            offsetAccum += addedHeight
        }
        print("frame: ", messageScrollView.frame.height)
        print("CS: ", messageScrollView.contentSize.height)
        print("VS: ", messageScrollView.visibleSize.height)
        print("AH: ", acumulatedHeight)
        print("OffsetAcc: ", offsetAccum)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfInput.delegate = self
        // Assign return key type to textfield
        self.tfInput.returnKeyType = UIReturnKeyType.send
        
        // Enable view to scroll
        messageScrollView.isScrollEnabled = true
        // Sets size of view
        /*messageScrollView.frame = CGRect(
            x: messageScrollView.frame.origin.x,
            y: messageScrollView.frame.origin.y,
            width: messageScrollView.frame.width,
            height: view.frame.height - 100)*/
        
        // Sets original position of toolbar
        toolBarOriginalFrame = inputToolBar.frame
        
        print("frame: ", messageScrollView.frame.height)
        print("CS: ", messageScrollView.contentSize.height)
        print("VS: ", messageScrollView.visibleSize.height)
        print("AH: ", acumulatedHeight)
        print("OffsetAcc: ", offsetAccum)
        
        configureNavBar()
        
        // Add notification observers for keyboard shown and hidden
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShows(aNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHides(aNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// This function toggles the side menu to show or not
    /// ```
    /// toggleMenuController() // Toggles the menu
    /// ```
    /// - Returns: Void
    func toggleMenuController(){
        let menuWidth =  self.messageScrollView.frame.width - CGFloat(menuLimit)
        
        if menuController == nil && shouldExpand{
            menuController = MenuController()
            //set menu controller dimensions
            menuController.view.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: self.view.frame.height)
            
            view.insertSubview(menuController.view, at: 0)
            addChild(menuController)
            menuController.didMove(toParent: self)
            print("Did add menu controller")
        }
        
        if shouldExpand{ //show menu
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.messageScrollView.frame.origin.x = self.messageScrollView.frame.width - CGFloat(self.menuLimit)
                self.inputToolBar.frame.origin.x = self.messageScrollView.frame.origin.x
                self.menuController.view.frame.origin.x = 0
            }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.messageScrollView.frame.origin.x = 0
                self.inputToolBar.frame.origin.x = 0
                self.menuController.view.frame.origin.x = -menuWidth
            }, completion: nil)
        }
        
        shouldExpand = !shouldExpand
    }
    
    func configureNavBar(){
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "hamburgerMenu70Pad").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMenuToggle))
        navigationItem.leftBarButtonItem = button
        
        // Temporary button for signing out
        let signOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(handleSignOut))
        navigationItem.rightBarButtonItem = signOutButton
    }
    
    // Show alert to end session with user
    @objc func handleSignOut() {
        // Create alert for sign out
        let alertController = UIAlertController(title: nil, message: "¿Seguro que quieres cerrar sesión?", preferredStyle: .actionSheet)
        
        // Add option to sign out in alert
        alertController.addAction(UIAlertAction(title: "Cerrar sesion", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        
        // Add option to cancel in alert
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        // Display alert
        present(alertController, animated: true, completion: nil)
    }
    
    // End session and return to loginVewController
    func signOut(){
        do {
            // Sign out user
            try Auth.auth().signOut()
            
            // Go to LoginViewController
            let loginViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginViewController) as? LoginViewController
            let navController = UINavigationController(rootViewController: loginViewController!)
            view.window?.rootViewController = navController
            view.window?.makeKeyAndVisible()
        }
        catch let error {
            print("Failed to sign out. Error: ", error)
        }
        
    }
    
    //gets called when pressing the navbar hamburger button
    @objc func handleMenuToggle(){
        toggleMenuController()
    }
    
    // Move messageScrollView when keyboard is shown
    @IBAction func keyboardShows(aNotification: NSNotification) {
        //obtains the keyboard size so we know how much to move
        let kbSize = (aNotification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
        //sets a contentInset taking into acount the keyboard size and the diferences between the size of the scroll and the viewcontroller
        let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height + inputToolBar.frame.height - (view.frame.size.height - messageScrollView.frame.origin.y - messageScrollView.frame.size.height), right: 0.0)
        
        messageScrollView.contentInset = contentInset
        messageScrollView.scrollIndicatorInsets = contentInset
        
        //moves the toolbar by the same amout as the keyboard size
        inputToolBar.frame = CGRect(
            x: inputToolBar.frame.origin.x,
            y: inputToolBar.frame.origin.y - kbSize.height + 34,
            width: inputToolBar.frame.width,
            height: inputToolBar.frame.height)
    }
    
    // Move messageScrollView when keyboard is hidden
    @IBAction func keyboardHides(aNotification: NSNotification) {
        //sets the tool bar back to its original position
        
        self.inputToolBar.frame.origin.y = self.toolBarOriginalFrame.origin.y
        /*UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
         self.inputToolBar.frame.origin.y = self.toolBarOriginalFrame.origin.y
         }, completion: nil)*/
        
        //resets the content insets to 0
        let contentInsets = UIEdgeInsets.zero
        messageScrollView.contentInset = contentInsets
        messageScrollView.scrollIndicatorInsets = contentInsets
        //?
        messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
    }
    
    //send button is pressed
    @IBAction func sendTapped(_ sender: Any) {
        send()
    }
    
    //tap action anywere on the view controller
    @IBAction func tapAction(_ sender: Any) {
        // Hide keyboard
        view.endEditing(true)
        
        if !shouldExpand{
            toggleMenuController()
        }
    }
    /*
     //tap action on the scroll
     @IBAction func tapOnScroll(_ sender: Any) {
     if !shouldExpand{
     toggleMenuController()
     }
     }
     
     //tap action on the toolbar
     @IBAction func tapOnToolBar(_ sender: Any) {
     if !shouldExpand{
     toggleMenuController()
     }
     }*/
    
    // This function prepares an HTTP request to the server that calls Dialogflow´s API
    func prepareRequest() {
        print("Preparing request")
        
        // Validate that the user's query is valid
        if let query = tfInput.text {
            
            // Create the query to solve
            let queryToSolve = Query(query: query, contexts: contexts)
            
            // Instantiate an APIRequest object that calls FAQ Agent
            let getRequest = APIRequest(endpoint: "faq/detectIntent")
            
            // Request promise
            getRequest.response(queryToSolve, completion: { result in
                switch result {
                // Request was successful and there is a Response JSON already decoded
                case .success(let response):
                    
                    // Store contexts from query
                    self.contexts.removeAll()
                    for context in response.outputContexts {
                        self.contexts.append(Context(name: context.name, lifespanCount: context.lifespanCount))
                    }
                    
                    print("Contexts self: \(self.contexts)")
                    print("FULL RESPONSE: \(response)\n")
                    print("FULFILLMENT_MESSAGES: \(response.fulfillmentMessages)\n")
                    print("OUTPUT_CONTEXTs: \(response.outputContexts)\n")
                    print("FULFILLMENT_TEXT: \(response.fulfillmentText)\n")
                    
                    // Does the display response in the main thread as UI changes in other treads do not behave correctly
                    DispatchQueue.main.async {
                        self.displayResponse(msg: response.fulfillmentText)
                    }
                    
                // Request went wrong
                case .failure(let error):
                    print("An error occured \(error).")
                }
            })
        }
            // text input is invalid
        else {
            return
        }
    }
    
    //when the user tries to send a message
    func send(){
        if tfInput.text != ""{
            addBubble(bbl: Bubble(view: messageScrollView, msg: Message(text: tfInput.text!, sender: "user")))
            
            //for testing only
            //addBubble(bbl: Bubble(view: messageScrollView, msg: Message(text: tfInput.text!, sender: "agent")))
            
            messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
            prepareRequest() //does the server request
        }
        
        tfInput.text = ""
    }
    
    //MARK: - text field delegate implementations
    
    //sends a user message if the return buttons is pressed on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        send()
        return false
    }
    
    // Each text field in the interface sets the view controller as its delegate.
    // Therefore, when a text field becomes active, it calls these methods.
    
    func textFieldDidBeginEditing (_ textField: UITextField )
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing (_ textField: UITextField )
    {
        activeField = nil
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


