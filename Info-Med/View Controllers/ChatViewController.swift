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

public enum Agent: String {
    case faq = "faq"
    case questionnaire = "questionnaire"
}

class ChatViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var messageScrollView: UIScrollView!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var btSend: UIButton!
    @IBOutlet var inputToolBar: UIToolbar!
    
    // Variables
    var menuController: UIViewController! //side menu view controller
    var isMenuHidden = true

    var menuLimit: CGFloat!
    
    var activeField: UITextField!
    var bubblesList: [Bubble]!  //list of chat bubbles were new bubbles are pushed to
    
    var contexts: [Context] = [Context]() // Declare empty Context array to store contexts from queries
    
    var acumulatedHeight = 0    //the virtual height of the bubbles areas, gets extended as new bubbles are added
    var offsetAccum = 0 //the inner view offset, must correspond to the accumulated height
    var toolBarOriginalFrame = CGRect(x: 0, y: 0, width: 0, height: 0) //the original position of the toolbar
    
    // Vars for agents
    var actualAgent: Agent = .faq
    var isNewChat = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfInput.delegate = self
        
        // Set max width side menu can have, is the horizontal space it can't cover
        menuLimit = self.view.frame.size.width / 4
        
        // Assign return key type to textfield
        tfInput.returnKeyType = UIReturnKeyType.send
        
        // Enable view to scroll
        messageScrollView.isScrollEnabled = true
        messageScrollView.alwaysBounceVertical = true
        // Sets size of view
        /*messageScrollView.frame = CGRect(
            x: messageScrollView.frame.origin.x,
            y: messageScrollView.frame.origin.y,
            width: messageScrollView.frame.width,
            height: view.frame.height - 100)*/
        
        // Gets original position of toolbar
        toolBarOriginalFrame = inputToolBar.frame
        
//        print("frame: ", messageScrollView.frame.height)
//        print("CS: ", messageScrollView.contentSize.height)
//        print("VS: ", messageScrollView.visibleSize.height)
//        print("AH: ", acumulatedHeight)
//        print("OffsetAcc: ", offsetAccum)
        
        createSideMenu()
        
        // Add sideMenu button to Navbar
        configureNavBar()
        
        // Configure initial chat
        startConversation()
        
        // Register to listen notification for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShows(aNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHides(aNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - NAVIGATION
    func configureNavBar(){
        
        // Make navbar transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        // Set configuration for menu button image and add button to NavBar
        let largeConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let button = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3", withConfiguration: largeConfig)!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMenuToggle))
        navigationItem.leftBarButtonItem = button
        
        // Temporary button for signing out
        let signOutButton = UIBarButtonItem(title: "Cerrar sesión", style: .plain, target: self, action: #selector(handleSignOut))
        navigationItem.rightBarButtonItem = signOutButton
    }
    
    // MARK: - SIDE MENU
    // This function creates the viewcontroller for the side menu
    func createSideMenu() {
        // Set menu's width
        let menuWidth =  messageScrollView.frame.width - menuLimit
        
        // Create sideMenu ViewController
        let labels = ["Mi cuenta", "Bot Covid-19", "Cuestionario médico", "Historial"]
        let icons = [UIImage(systemName: "person.fill")!, UIImage(systemName: "bubble.left.fill")!, UIImage(systemName: "doc.text.magnifyingglass")!, UIImage(systemName: "tray.full.fill")!]
        menuController = MenuController(labels: labels, icons: icons)
        
        // Set menu dimensions and position
        menuController.view.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: self.view.frame.height)
        
        // Add subview of menu to ChatViewController
        view.insertSubview(menuController.view, at: 0)
        addChild(menuController)
        menuController.didMove(toParent: self)
        print("Added menu controller to ChatViewController")
    }
    
    //gets called when pressing the navbar hamburger button
    @objc func handleMenuToggle(){
        toggleMenuController()
    }

    /// This function toggles the side menu to show or hide
    /// ```
    /// toggleMenuController() // Toggles the menu
    /// ```
    /// - Returns: Void
    func toggleMenuController(){
        // Show menu
        if isMenuHidden {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                // Slide chat content to the right
                self.messageScrollView.frame.origin.x = self.messageScrollView.frame.width - self.menuLimit
                self.inputToolBar.frame.origin.x = self.messageScrollView.frame.origin.x
                self.menuController.view.frame.origin.x = 0
            }, completion: nil)
        }
        // Hide menu
        else {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                // Slide chat content to the origin
                self.messageScrollView.frame.origin.x = 0
                self.inputToolBar.frame.origin.x = 0
                self.menuController.view.frame.origin.x = -self.menuController.view.frame.width
            }, completion: nil)
        }
        
        isMenuHidden = !isMenuHidden
    }

    // MARK: - CHAT
    // This function initializes the conversation with the chatbot depending on the agent chosen by the user
    func startConversation() {
        switch actualAgent {
        case .faq:
            prepareRequest(userInput: "Hola", agent: .faq)
        default:
            prepareRequest(userInput: "Iniciar cuestionario", agent: .questionnaire)
        }
        
    }
    
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
            y: inputToolBar.frame.origin.y - kbSize.height + 28,
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
        
        if !isMenuHidden{
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
    
    // This function is called when the user sends a message to add bubble to the screen and make the request to Dialogflow
    func send(){
        if tfInput.text != ""{
            addBubble(bbl: Bubble(view: messageScrollView, msg: Message(text: tfInput.text!, sender: "user")))
            
            //for testing only
            //addBubble(bbl: Bubble(view: messageScrollView, msg: Message(text: tfInput.text!, sender: "agent")))
            
            messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
            prepareRequest(userInput: tfInput.text!, agent: actualAgent) //does the server request
        }
        
        tfInput.text = ""
    }
    
    // MARK: - HTTP REQUEST
    
    // This function prepares an HTTP request to the server that calls Dialogflow´s API
    func prepareRequest(userInput: String!, agent: Agent!) {
        print("Preparing request")
        
        // Validate that the user's query is valid
        if let query = userInput {
            
            // Create the query to solve
            let queryToSolve = Query(query: query, contexts: contexts)
            
            // Instantiate an APIRequest object that calls FAQ Agent
            let getRequest = APIRequest(endpoint: "\(agent.rawValue)/detectIntent")
            
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
        // Text input is invalid, do nothing
        else {
            return
        }
    }
    
    
    
    
    
    
    
    // MARK: - SESSION
    
    // Show alert to end session with user
    @objc func handleSignOut() {
        // Create alert for sign out
        let alertController = UIAlertController(title: nil, message: "¿Seguro que quieres cerrar sesión?", preferredStyle: .actionSheet)
        
        // Add option to sign out in alert
        alertController.addAction(UIAlertAction(title: "Cerrar sesión", style: .destructive, handler: { (_) in
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
    
   
    
    
    
    //MARK: - TEXT FIELD DELEGATES
    
    // Sends user's query if the return buttons is pressed on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
}


