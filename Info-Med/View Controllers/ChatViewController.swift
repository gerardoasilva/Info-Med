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
import FirebaseFirestore

class ChatViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, OptionBubbleActionProtocol, UIScrollViewDelegate {
    
    // Outlets
    @IBOutlet weak var messageScrollView: UIScrollView!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var btSend: UIButton!
    @IBOutlet var inputToolBar: UIToolbar!
    
    // Chat variables
    var menuView: UIView! // Side menu view
    var isMenuHidden = true
    var darkView: UIView! // Darkens the chat when menu is open
    var menuLimit: CGFloat!
    var activeField: UITextField!
    var bubblesList: [Bubble]!  // List of chat bubbles were new bubbles are pushed to
    var contexts: [Context] = [Context]() // Empty context array to store contexts from chat queries
    var lastSuperBubble: BubbleOfBubbles!
    var typingBubbleIsPresent = false
    private var keyBSize: CGSize!
    var menuRightConstraint: NSLayoutConstraint!

    // Questionary specific variables
    var symptomsDict: [String : Double]! // Saves the symptoms and its metric of the current questionary
    var currentSymptom: String! // Saves the current cuestion symptom
    
    var acumulatedHeight = 0    // The virtual height of the bubbles areas displayed, it increases as new bubbles are added
    var offsetAccum = 0 // The inner view offset, must correspond to the accumulated height
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint! // Outlet constraint to move the Tool Bar
    
    // Vars for agents
    var actualAgent: Agent = .faq // Inicializa el agente de preguntas frecuentes
    var isNewChat = true
    
    // Function to initialzie and setup elements for chat
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfInput.delegate = self
        
        // Set max width the side menu can cover of the screen
        menuLimit = self.view.frame.size.width / 4
        
        // Configure scroll view
        messageScrollView.isScrollEnabled = true
        messageScrollView.alwaysBounceVertical = true
        messageScrollView.keyboardDismissMode = .onDrag
        
        // Style tfInput
        setupTextField()
        
        // Add sideMenu button to Navbar
        configureNavBar()
        
        // Display agent's introduction
        if isNewChat {
            // Configure initial chat
            startConversation()

        }
        
        // Initialize side menu
        if menuView == nil {
            createSideMenu()
        }
           
        // Add tap and swiope gesture to close menu when tapped outside of it
        let closeMenuTap = UITapGestureRecognizer(target: self, action: #selector(self.handleMenuToggle(_:)))
        let closeMenuSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleMenuToggle(_:)))
        closeMenuSwipe.direction = .left
        darkView.addGestureRecognizer(closeMenuSwipe)
        darkView.addGestureRecognizer(closeMenuTap)
        
        // Add tap gesture to scroll view to hide keyboard
        let closeKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        messageScrollView.addGestureRecognizer(closeKeyboard)
        
        // Register to listen notification for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Register to listen notification for menu option 'Cuestionario"
        NotificationCenter.default.addObserver(self, selector: #selector(optionSelectionHandler(notification:)), name: MenuView.notificationOption, object: nil)
    }
    
    // Function to setup nav bar style
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .none
        
        // Show menu if it should be shown
        if !isMenuHidden && menuView.frame.origin.x < 0 {
            isMenuHidden = !isMenuHidden
            handleMenuToggle()
        }
    }
    
    // MARK: - NAVIGATION
    // Function to configure style of navbar and buttons
    func configureNavBar(){
        
        // Make navbar transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        // Add side menu button to navbar
        let largeConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let button = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3", withConfiguration: largeConfig)!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMenuToggle))
        navigationItem.leftBarButtonItem = button
        
        // Add credits button to navbar
        let creditsbutton = UIBarButtonItem(image: UIImage(systemName: "info.circle", withConfiguration: largeConfig)!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(presentCredits))
        navigationItem.rightBarButtonItem = creditsbutton
        
        // Style for pushed view controller's navbar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 1)
    }
    
    // Function that transitions to CreditsVC
    @objc func presentCredits(){
        self.performSegue(withIdentifier: "presentCredits", sender: self)
    }
    
    // MARK: - SIDE MENU
    
    // Function to handle selected option by user from the side menu
    @objc func optionSelectionHandler(notification: NSNotification?) {
        // Check if there is a selected option notification
        if let optionSelected = (notification?.object) as? MenuOption {
            
            // Clear the questionaire variables if the user changes agent
            if actualAgent != .questionnaire{
                //clear the dictionary to be able to use it again
                self.symptomsDict = nil
                self.currentSymptom = nil
            }
            
            switch optionSelected {
            // Display user info viewController
            case .info:
                print("INFO listened")
                let infoTableViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.infoTableViewController) as? InfoTableViewController
                  
                self.navigationController?.pushViewController(infoTableViewController!, animated: true)
                
            // Change chatbot to FAQ
            case .faq:
                print("FAQ listened")
                // Close menu
                handleMenuToggle()
                
                // Update actual agent
                if actualAgent != .faq {
                    actualAgent = .faq
                    
                    // Delete actual conversation and start conversation with new agent
                    startConversation()
                }
                
            // Change chatbot to Questionnaire
            case .questionnaire:
                print("QUESTIONNAIRE listened")
                // Close menu
                handleMenuToggle()
                                
                // Update actual agent
                if actualAgent != .questionnaire {
                    actualAgent = .questionnaire
                    
                    // Delete actual conversation and start conversation with new agent
                    startConversation()
                }
                
            // Display history view controller
            case .history:
                print("HISTORY listened")
                let historyTableViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.historyTableViewController) as? HistoryTableViewController
                self.navigationController?.pushViewController(historyTableViewController!, animated: true)
                
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
        let toolBarFrame = inputToolBar.frame
        let scrollViewFrame = messageScrollView.frame
        
        // Create menu view
        menuView = MenuView(toolBarFrame: toolBarFrame, scrollViewFrame: scrollViewFrame)

        // Create dark view
        darkView = UIView()
        
        // Set menuView and darkView dimensions and position
        menuView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        darkView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        // Add subviews to ChatViewController
        view.addSubview(darkView)
        view.addSubview(menuView)

        // DarkView style
        darkView.backgroundColor = .black
        darkView.alpha = 0
        darkView.isUserInteractionEnabled = false
        menuView.translatesAutoresizingMaskIntoConstraints = false
        darkView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraint outlet of menu
        menuRightConstraint = menuView.rightAnchor.constraint(equalTo: self.view.leftAnchor)

        // Add constraints of menu and side view
        NSLayoutConstraint.activate([
            menuRightConstraint,
            menuView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            menuView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 3/4),
            menuView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            darkView.leftAnchor.constraint(equalTo: menuView.rightAnchor, constant: -50),
            darkView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            darkView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            darkView.topAnchor.constraint(equalTo: self.view.topAnchor)
            
        ])
    }
    
    // Function that handles side menu when pressing on the navbar's hamburguer button
    @objc func handleMenuToggle(_ sender: UITapGestureRecognizer? = nil){
        toggleMenu()
    }
    
    /// This function toggles the side menu to show or hide
    /// ```
    /// toggleMenuController() // Toggles the menu
    /// ```
    /// - Returns: Void
    func toggleMenu(){
        
        // Set menu's width
        let menuWidth =  UIScreen.main.bounds.width - menuLimit
        // Show menu
        if isMenuHidden {
            
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                
                // Slide chat content to the right
                self.view.endEditing(true)
                self.menuRightConstraint.constant = menuWidth
                self.menuView.layer.shadowOpacity = 1
                self.darkView.alpha = 0.2
                self.darkView.isUserInteractionEnabled = true
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        // Hide menu
        else {
            navigationItem.rightBarButtonItem?.isEnabled = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                // Slide chat content to the origin
                self.menuRightConstraint.constant = 0
                self.menuView.layer.shadowOpacity = 0
                self.darkView.alpha = 0
                self.darkView.isUserInteractionEnabled = false
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        // Update bool
        isMenuHidden = !isMenuHidden
    }
    
    // MARK: - CHAT
    
    // Function to add style for the input text field
    func setupTextField() {
        tfInput.font = UIFont(name: "HelveticaNeue", size: 18)
        tfInput.returnKeyType = UIReturnKeyType.send
        tfInput.layer.borderColor = #colorLiteral(red: 0.8352941176, green: 0.8470588235, blue: 0.8588235294, alpha: 1)
        tfInput.backgroundColor = .white
        tfInput.layer.borderWidth = 1.0
        tfInput.layer.cornerRadius = tfInput.frame.height / 2
        tfInput.setLeftPaddingPoints(10)
        tfInput.setRightPaddingPoints(10)
    }
    
    // This function clears the chat and starts a conversation with the chatbot depending on the agent chosen by the user
    func startConversation() {
        // Update bool to indicate chat has begun
        self.isNewChat = false
        // Delete all bubbles from list
        bubblesList = nil
        // Delete all contexts from list
        contexts.removeAll()
        // Delete all chat bubblesfrom screen
        messageScrollView.subviews.forEach({ $0.removeFromSuperview() })
        acumulatedHeight = 0
        offsetAccum = 0
        
        // Display agent's introduction depending on the chat selected
        switch actualAgent {
        case .faq:
            // Call the intent for faq introduction
            prepareRequest(userInput: "Hola", agent: .faq)
        default:
            // Call intent for questionnaire introduction
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
        // Add agent's response bubble to list of bubbles
        addBubble(bbl: Bubble(view: messageScrollView ,msg: Message(text: msg, sender: "agent")))
        
        // Scroll the screen to the last message displayed
        if messageScrollView.contentSize.height > messageScrollView.frame.size.height  {
            let bottomOffset: CGPoint!
            // Scroll the screen to the beggining of last bubble added if it is grerater than the screen size
            if let lastBubbleFrame = bubblesList.last?.frame, lastBubbleFrame.size.height > messageScrollView.frame.size.height {
                bottomOffset = CGPoint(x: 0, y: messageScrollView.contentSize.height - (lastBubbleFrame.size.height + 20))
            } else {
                bottomOffset = CGPoint(x: 0, y: messageScrollView.contentSize.height - messageScrollView.frame.size.height)
            }
            // Set offset to move content animated
            messageScrollView.setContentOffset(bottomOffset, animated: true)
        }
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
    
    // Function that removes the last bubble from the scrroll view and bubble list. It also resets the height, accum height, and offset
    func removeLastBubble(){
        if bubblesList == nil {
            return
        }
        
        let index = bubblesList.count - 1 // The last index in the array
        
        if index + 1 >= 1{
            // The bubble to remove
            let bbl = bubblesList[index]
            
            // If it is the last remaining bubble
            if index + 1 == 1{
                acumulatedHeight -= bbl.padd
                messageScrollView.contentSize.height = CGFloat(acumulatedHeight)
            }
            
            let subtractedHeight = Int(bbl.frame.height) + bbl.padd
            acumulatedHeight -= subtractedHeight
            messageScrollView.contentSize.height = CGFloat(acumulatedHeight )
            
            bbl.deleteIcon()
            bbl.removeFromSuperview()
            bubblesList.removeLast()
            
            // If it is the last remaining bubble
            if index + 1 == 1{
                bubblesList = nil
            }
            
            // Check if content is larger than scroll view's actual height
            if CGFloat(messageScrollView.contentSize.height) >= messageScrollView.frame.height {
                // Remove height from offset
                offsetAccum -= subtractedHeight
            }
        }
    }
    
    // Move messageScrollView when keyboard is shown
    @IBAction func keyboardWillShow(notification: NSNotification) {
        // Get the keyboard size
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
        self.keyBSize = keyboardSize
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
        if (scrollContentSizeHeight > scrollViewHeight - keyboardSize.height && messageScrollView.contentOffset.y >= messageScrollView.frame.size.height - keyboardSize.height) {
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
        if scrollOffset > scrollViewHeight {
            let offset = CGPoint(x: 0, y: scrollOffset-keyboardSize.height+self.view.safeAreaInsets.bottom)
            messageScrollView.setContentOffset(offset, animated: false)
        }
    }
    
    // Send button is pressed
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
            
            // Temove the typing bubble if it exists, before adding the next typing bubble and the user's bubble
            if typingBubbleIsPresent{
                self.removeLastBubble()
                typingBubbleIsPresent = false
            }
            
            // Add bubble to bubble list
            addBubble(bbl: Bubble(view: messageScrollView, msg: Message(text: tfInput.text!, sender: "user")))
            
            // Move chat content
            if messageScrollView.contentSize.height > messageScrollView.frame.size.height {
                let bottomOffset = CGPoint(x: 0, y: messageScrollView.contentSize.height - messageScrollView.frame.size.height)
                messageScrollView.setContentOffset(bottomOffset, animated: true)
            }
            // Request response from server
            prepareRequest(userInput: tfInput.text!, agent: actualAgent)
        }
        
        tfInput.text = ""
    }
    
    
    // MARK: - CHAT OPTION BUBBLE PROTOCOL IMPLEMENTATION
    
    // Function called when agent suggestion is tapped
    func onOptionBubblePress(text: String) {
        messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
        prepareRequest(userInput: text, agent: actualAgent) // Does the server request as if the user sent it
        print("Suggestion sent\n")
    }
    
    // MARK: - HTTP REQUEST
    
    // This function prepares an HTTP request to the server that calls Dialogflow´s API
    func prepareRequest(userInput: String!, agent: Agent!) {
        print("Preparing request")
                
        // Add the (...) typing bubble to indicate that a request is being fulfilled
        addBubble(bbl: TypingBubble(view: messageScrollView))
        typingBubbleIsPresent = true
        
        // Block user interaction with past agent suggestions
        if lastSuperBubble != nil{
            lastSuperBubble.blockFurtherActions(bbl: nil)
        }
        
        // Validate the user's query
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
                    
                    print("FULL RESPONSE: \(response)\n")
                                        
                    // Does the display response in the main thread as UI changes in other treads do not behave correctly
                    DispatchQueue.main.async {
                        
                        // Remove the typing bubble if present, before pushing the response bubble
                        if self.typingBubbleIsPresent{
                            self.removeLastBubble()
                            self.typingBubbleIsPresent = false
                        }
                        
                        // Display the bot's response
                        self.displayResponse(msg: response.fulfillmentText)
                        
                        // Initialize the symptoms dictionary if needed
                        if self.symptomsDict == nil{
                            self.symptomsDict = [:]
                        }
                        
                        // Process each fulfillment message
                        var options : [OptionBubble]!
                        for fm in response.fulfillmentMessages {
                            
                            // Save the syptoms clinimetry to the disctionary
                            if let clinimetry = fm.payload?.fields.clinimetry?.numberValue { // If there is some clinimetry to process
                                
                                if clinimetry == 0 { // It is the firs question of the queationaire
                                    
                                    // Set currentSyptom to the question symptom for cases where the question is missing the symptom
                                    if let symptom = fm.payload?.fields.symptom?.stringValue {
                                        self.currentSymptom = symptom
                                    }
                                } else { // Add the previous question clinimetry to the symptom
                                    
                                    var symp = fm.payload?.fields.symptom?.stringValue
                                    print("SYMP: \(String(describing: symp))")
                                    
                                    if symp == nil { // If the answere doesn't have a symptom use the questions default
                                        symp = self.currentSymptom
                                    }
                                    
                                    // Check if key is already in dictionary and add clinimetry value
                                    if self.symptomsDict[symp!] == nil {
                                         self.symptomsDict[symp!] = Double(clinimetry)
                                    } else {
                                        self.symptomsDict[symp!]! += Double(clinimetry)
                                    }
                                }
                            }
                            
                            // Check if the suggestions array is empty
                            var sugEmpty = false
                            if fm.payload != nil && fm.payload?.fields.suggestions != nil{
                                if ((fm.payload?.fields.suggestions?.listValue.values.isEmpty)!){
                                    sugEmpty = true
                                }
                            }
                                
                            // Push dictionary to DB when the poll is finnished. That is indicated by an empty suggestions array. Do not push if there is nothing to push
                            if  sugEmpty && self.symptomsDict != nil{
                                print("Pushing to DB!!")
                                print("DIC TO PUSH = \(String(describing: self.symptomsDict))")
                                
                                let db = Firestore.firestore()
                                let user = Auth.auth().currentUser
                                
                                print("USER = \(String(describing: user?.uid))")
                                
                                var docID : String!
                                
                                // Query to get the current user's document id
                                db.collection("users").whereField("uid", isEqualTo: user!.uid).getDocuments {(snapshot, error) in
                                    if let error = error {
                                        print("Error geting user document: \(error)")
                                    }else{
                                        // Iterate the documents resulting from the query
                                        for document in snapshot!.documents{
                                            let data = document.data()
                                            docID = document.documentID
                                            
                                            print("USER NAME = \(String(describing: data["firstName"]))")
                                            print("DOC ID = \(String(describing: document.documentID))")
                                        }
                                    }
                                    
                                    // If the query was succesful then add a document with the poll results
                                    if(docID != nil && self.symptomsDict != nil){
                                        // Prepare date data to be used as document id name
                                        let date = Date()
                                        let calendar = Calendar.current
                                        let sec = calendar.component(.second, from: date)
                                        let minutes = calendar.component(.minute, from: date)
                                        let hour = calendar.component(.hour, from: date)
                                        let day = calendar.component(.day, from: date)
                                        let month = calendar.component(.month, from: date)
                                        let year = calendar.component(.year, from: date)
                                        
                                        // Add poll results to database
                                        db.collection("users").document(docID).collection("polls").document("\(year) \(month) \(day) \(hour) \(minutes) \(sec)").setData(self.symptomsDict)
                                    } else {
                                        print("No doc ID")
                                    }
                                    // Clear the dictionary to be able to use it again
                                    self.symptomsDict = nil
                                }
                            }
                            
                            // Display an option bubble for each suggestion
                            if let values = fm.payload?.fields.suggestions?.listValue.values {
                                let len = values.count
                                
                                for i in 0..<len {
                                    let toBeAdded = OptionBubble(view: self.messageScrollView, msg: Message(text: values[i].stringValue, sender: "option"), sTxt: String(i + 1), pd: 2, del: self )
                                    
                                    if options == nil {
                                        options = [toBeAdded]
                                    } else {
                                        options.append(toBeAdded)
                                    }
                                }
                                // Create a supper bubble that contains all thesuggestion bubbles
                                if options != nil && !options.isEmpty {
                                    let superBubble = BubbleOfBubbles(view: self.messageScrollView, subB: options, send: "option")
                                    self.addBubble(bbl: superBubble)
                                    self.lastSuperBubble = superBubble
                                    
                                    // Scroll chat to last bubble of suggestions added
                                    if self.messageScrollView.contentSize.height > self.messageScrollView.frame.size.height  {
                                        let bottomOffset = CGPoint(x: 0, y: self.messageScrollView.contentSize.height - self.messageScrollView.frame.size.height)
                                        self.messageScrollView.setContentOffset(bottomOffset, animated: true)
                                    }
                                }
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
