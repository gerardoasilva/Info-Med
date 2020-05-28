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



class ChatViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, OptionBubbleActionProtocol {
    
    // Outlets
    @IBOutlet weak var messageScrollView: UIScrollView!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var btSend: UIButton!
    @IBOutlet var inputToolBar: UIToolbar!
    
    // Variables
    var menuView: UIView! // Side menu view
    var isMenuHidden = true
    var darkView: UIView! // Darkens the screen when menu is open
    
    var menuLimit: CGFloat!
    
    var activeField: UITextField!
    var bubblesList: [Bubble]!  //list of chat bubbles were new bubbles are pushed to
    
    var contexts: [Context] = [Context]() // Declare empty Context array to store contexts from queries
    
    var acumulatedHeight = 0    //the virtual height of the bubbles areas, gets extended as new bubbles are added
    var offsetAccum = 0 //the inner view offset, must correspond to the accumulated height
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint! // Outlet to move the inputbar
    
    // Vars for agents
    var actualAgent: Agent = .faq
    var isNewChat = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfInput.delegate = self
        
        // Set max width side menu can have, is the horizontal space it can't cover
        menuLimit = self.view.frame.size.width / 4
        
        // Enable view to scroll
        messageScrollView.isScrollEnabled = true
        messageScrollView.alwaysBounceVertical = true
        messageScrollView.keyboardDismissMode = .onDrag
        
        // Style tfInput
        setupTextField()
        
        // Add sideMenu button to Navbar
        configureNavBar()
        
        if isNewChat {
            // Configure initial chat
            //startConversation()
            startConversation()

        }
        
        if menuView == nil {
            createSideMenu()
        }
           
        // Add tap gesture to close menu when tapped outside of it
        let closeMenuTap = UITapGestureRecognizer(target: self, action: #selector(self.handleMenuToggle(_:)))
        let closeMenuSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleMenuToggle(_:)))
        closeMenuSwipe.direction = .left
        darkView.addGestureRecognizer(closeMenuSwipe)
        darkView.addGestureRecognizer(closeMenuTap)
        
        // Add tap gesture to close keyboard when
        let closeKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        messageScrollView.addGestureRecognizer(closeKeyboard)
        
        // Register to listen notification for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Register to listen notification for menu option 'Cuestionario"
        NotificationCenter.default.addObserver(self, selector: #selector(optionSelectionHandler(notification:)), name: MenuView.notificationOption, object: nil)
        
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
        
    }
    
    // MARK: - SIDE MENU
    
    // Function to handles user optionSelection from the side menu
    @objc func optionSelectionHandler(notification: NSNotification?) {
        
        if let optionSelected = (notification?.object) as? MenuOption {
            switch optionSelected {
            // Display user info viewController
            case .info:
                print("INFO listened")
                /*
                    Do user info stuff
                 */
                
            // Change chatbot to FAQ
            case .faq:
                print("FAQ listened")
                handleMenuToggle()
                
                if actualAgent != .faq {
                    actualAgent = .faq
                    
                    // PENDING: Save data of conversation in history
                    
                    // Delete actual conversation
                    startConversation()
                    
                }
                
            // Change chatbot to questionnaire
            case .questionnaire:
                print("QUESTIONNAIRE listened")
                handleMenuToggle()

                if actualAgent != .questionnaire {
                    actualAgent = .questionnaire
                    
                    // PENDING: Save data of conversation in history
                    
                    // Delete actual conversation
                    startConversation()
                    
                }
                
            // Show hitory of interactions
            case .history:
                print("HISTORY listened")
                /*
                    Do hisotry stuff
                 */
                
            // SignOut
            default:
                print("SIGNOUT listened")
                handleSignOut()
                break
            }
        }
    }
    
    // This function creates the viewcontroller for the side menu
    func createSideMenu() {
        // Set menu's width
        let menuWidth =  UIScreen.main.bounds.width - menuLimit
        let toolBarFrame = inputToolBar.frame
        let scrollViewFrame = messageScrollView.frame
        
        menuView = MenuView(toolBarFrame: toolBarFrame, scrollViewFrame: scrollViewFrame)
        // Create dark view
        darkView = UIView()
        
        // Set menuView and darkViewdimensions and position
        menuView.frame = CGRect(x: -UIScreen.main.bounds.width, y: 0, width: menuWidth, height: self.view.frame.height)
        darkView.frame = CGRect(x: -menuWidth, y: 0, width: menuLimit, height: self.view.frame.height)
        
        // Add subview of menu to ChatViewController
        view.addSubview(menuView)
        view.addSubview(darkView)
        
        // DarkView style
        darkView.backgroundColor = .black
        darkView.alpha = 0
        menuView.translatesAutoresizingMaskIntoConstraints = false
        
        setupMenu()
        
        print("Added menu view to ChatViewController")
    }
    
    func setupMenu() {
        
    }
    
    //gets called when pressing the navbar hamburger button
    @objc func handleMenuToggle(_ sender: UITapGestureRecognizer? = nil){
        toggleMenu()
    }
    
    /// This function toggles the side menu to show or hide
    /// ```
    /// toggleMenuController() // Toggles the menu
    /// ```
    /// - Returns: Void
    func toggleMenu(){
        // Show menu
        if isMenuHidden {
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                
                // Slide chat content to the right
                self.view.endEditing(true)
                self.messageScrollView.frame.origin.x = self.messageScrollView.frame.width - self.menuLimit
                self.inputToolBar.frame.origin.x = self.messageScrollView.frame.origin.x
                self.menuView.frame.origin.x = 0
                self.menuView.layer.shadowOpacity = 1
                self.darkView.frame.origin.x = self.menuView.frame.width
                self.darkView.alpha = 0.2
                self.darkView.isUserInteractionEnabled = true
            }, completion: nil)
        }
            // Hide menu
        else {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                // Slide chat content to the origin
                self.messageScrollView.frame.origin.x = 0
                self.inputToolBar.frame.origin.x = 0
                self.menuView.frame.origin.x = -self.menuView.frame.width - self.darkView.frame.width
                self.menuView.layer.shadowOpacity = 0
                self.darkView.frame.origin.x = -self.menuLimit
                self.darkView.alpha = 0
                self.darkView.isUserInteractionEnabled = false
            }, completion: nil)
        }
        
        isMenuHidden = !isMenuHidden
    }
    
    // MARK: - CHAT
    
    func setupTextField() {
        tfInput.returnKeyType = UIReturnKeyType.send
        tfInput.layer.borderColor = #colorLiteral(red: 0.8352941176, green: 0.8470588235, blue: 0.8588235294, alpha: 1)
        tfInput.backgroundColor = .white
        tfInput.layer.borderWidth = 1.0
        tfInput.layer.cornerRadius = tfInput.frame.height / 2
        tfInput.setLeftPaddingPoints(10)
        tfInput.setRightPaddingPoints(10)
    }
    
    // This function initializes the conversation with the chatbot depending on the agent chosen by the user
    func startConversation() {
        // Delete all bubbles
        bubblesList = nil
        // Delete all contexts
        contexts.removeAll()
        // Delete chat from screen
        messageScrollView.subviews.forEach({ $0.removeFromSuperview() })
        acumulatedHeight = 0
        offsetAccum = 0
        

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
        addBubble(bbl: Bubble(view: messageScrollView ,msg: Message(text: msg, sender: "agent")))
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
    }
    
    //Removes the last bubble from the scrroll view, bubble array, and resets the height, accum height, and offset
    func removeLastBubble(){
        if bubblesList == nil {
            return
        }
        
        let index = bubblesList.count - 1 //the last index in the array
        
        if index + 1 >= 1{
            //the bubble to remove
            let bbl = bubblesList[index]
            
            //if it is the last remaining bubble
            if index + 1 == 1{
                acumulatedHeight -= bbl.padd
                messageScrollView.contentSize.height = CGFloat(acumulatedHeight)
            }
            
            let subtractedHeight = Int(bbl.frame.height) + bbl.padd
            acumulatedHeight -= subtractedHeight
            messageScrollView.contentSize.height = CGFloat(acumulatedHeight )
            
            bbl.removeFromSuperview()
            bubblesList.removeLast()
            //if it is the last remaining bubble
            if index + 1 == 1{
                bubblesList = nil
            }
            
            // Check if content is larger than scroll view's actual height
            if CGFloat(messageScrollView.contentSize.height) >= messageScrollView.frame.height {
                // remove height from offset
                offsetAccum -= subtractedHeight
            }
            
            /*for b in bubblesList{
                b.updateNeighbors(arr: bubblesList)
            }*/
        }
    }
    
    // Move messageScrollView when keyboard is shown
    @IBAction func keyboardWillShow(notification: NSNotification) {
        // Get the keyboard size
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
        let scrollViewHeight = messageScrollView.frame.size.height;
        let scrollContentSizeHeight = messageScrollView.contentSize.height;
        let scrollOffset = messageScrollView.contentOffset.y;
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        

        // Move inputToolBar over the keyboard
        self.toolBarBottomConstraint.constant = -keyboardSize.height + self.view.safeAreaInsets.bottom
        
        // Animate keyboard movement
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            
        }
        
        // Scroll content up when keyboard shows
        if (scrollContentSizeHeight > scrollViewHeight) {
            // Scroll content up
            self.messageScrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset + keyboardSize.height - self.view.safeAreaInsets.bottom), animated: false)
        }
    }
        
    // Move messageScrollView when keyboard is hidden
    @IBAction func keyboardWillHide(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
        let scrollViewHeight = messageScrollView.frame.size.height;
        let scrollOffset = messageScrollView.contentOffset.y;
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        // Change constant for inputTollBar constraint
        self.toolBarBottomConstraint.constant = 0
        
        // Animate keyboard movement
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
        // Scroll content down when keyboard hides
        if (scrollOffset > scrollViewHeight - (keyboardSize.height + self.view.safeAreaInsets.bottom)) {
            // Scroll content up
            //scrollContentSizeHeight - (scrollViewHeight-keyboardSize.height)
            self.messageScrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset - keyboardSize.height + self.view.safeAreaInsets.bottom), animated: false)
        }
    }
    
    //send button is pressed
    @IBAction func sendTapped(_ sender: Any) {
        send()
    }
    
    // Tap handler to hide keyboard when tapped anywhere outside the keyboard
    @IBAction func handleTap(_ sender: Any) {
        
        // Hide keyboard
        view.endEditing(true)
        
        if !isMenuHidden{
            toggleMenu()
        }
    }
    
    // This function is called when the user sends a message to add bubble to the screen and make the request to Dialogflow
    func send(){
        if tfInput.text != ""{
            addBubble(bbl: Bubble(view: messageScrollView, msg: Message(text: tfInput.text!, sender: "user")))
            
            messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
            prepareRequest(userInput: tfInput.text!, agent: actualAgent) //does the server request
        }
        
        tfInput.text = ""
    }
    
    // MARK: - CHAT OPTION BUBBLE PROTOCOL IMPLEMENTATION
    
    func onOptionBubblePress(text: String) {
        messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
        prepareRequest(userInput: text, agent: actualAgent) //does the server request as if the user sent it
        print("Suggestion sent\n")
    }
    
    // MARK: - HTTP REQUEST
    
    // This function prepares an HTTP request to the server that calls Dialogflow´s API
    func prepareRequest(userInput: String!, agent: Agent!) {
        print("Preparing request")
        
        addBubble(bbl: TypingBubble(view: messageScrollView))
        
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
                                        
                    // Does the display response in the main thread as UI changes in other treads do not behave correctly
                    DispatchQueue.main.async {
                        
                        //remove the typing bubble
                        self.removeLastBubble()
                        //display the bot response
                        self.displayResponse(msg: response.fulfillmentText)
                        
                        var options : [OptionBubble]!
                        
                        //process each fulfillment message and display an option bubble for each suggestion
                        for fm in response.fulfillmentMessages{
                            
                            if let values = fm.payload?.fields.suggestions?.listValue.values{
                                let len = values.count
                                
                                for i in 0..<len{
                                    let toBeAdded = OptionBubble(view: self.messageScrollView, msg: Message(text: values[i].stringValue, sender: "option"), sTxt: String(i + 1), pd: 2, del: self )
                                    
                                    if options == nil {
                                        options = [toBeAdded]
                                    }else{
                                        options.append(toBeAdded)
                                    }
                                }
                                //create a supper bubble that contains all thesuggestion bubbles 
                                let superBubble = BubbleOfBubbles(view: self.messageScrollView, subB: options, send: "option")
                                self.addBubble(bbl: superBubble)
                            }
                        }
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

// MARK: - CLASS MENU VIEW


// Class extension to add padding to textField
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
