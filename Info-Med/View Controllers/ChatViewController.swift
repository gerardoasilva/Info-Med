//
//  ChatViewController.swift
//  Info-Med
//
//  Created by user168593 on 4/21/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
// something

import UIKit
import AVFoundation

public struct FAQ: Codable {
    var textInput: String
}

class ChatViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var messageScrollView: UIScrollView!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var btSend: UIButton!
    @IBOutlet var inputToolBar: UIToolbar!
    
    var activeField: UITextField!
    
    var aBubble: Bubble!
    var bubblesList: [Bubble]!
    var acumulatedHeight = 0
    var offsetAccum = 0
    var toolBarOriginalFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    let speechSynthesizer = AVSpeechSynthesizer()

    /// This function displays a message bubble from agent in messageScrollView
    ///
    /// ```
    /// displayResponse("Bienvenido") // Displays bubble with "Bienvenido"
    /// ```
    /// - Parameter msg: The string to be displayed
    /// - Returns: Void
    func displayResponse(msg: String) {
        print("Request completed")
        
        //if tfInput.text != ""{
        addBubble(bbl: Bubble(view: messageScrollView, msg: Message(text: msg, sender: "agent")))
        //messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
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
        }
        // Not the first bubble
        else {
            bubblesList.append(bbl)
        }
        // Store the height added by bubble in the view
        let addedHeight = Int(bbl.frame.height) + bbl.padd
        // Set position to bubble added
        bbl.setY(y: CGFloat(acumulatedHeight + bbl.padd))
        // Update the accumulated height in the view
        acumulatedHeight += addedHeight
        // Add view with bubble to scroll view
        messageScrollView.addSubview(bbl)
        // Update size of scroll view's content
        messageScrollView.contentSize.height = CGFloat(acumulatedHeight)
        
        // Check if content is larger than scroll view's actual height
        if CGFloat(acumulatedHeight + bbl.padd) > messageScrollView.frame.height {
            // Add height to offset
            offsetAccum += addedHeight
        }
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfInput.delegate = self
        // Assign return key type to textfield
        self.tfInput.returnKeyType = UIReturnKeyType.send
        // Enable view to scroll
        messageScrollView.isScrollEnabled = true
        // Sets size of view
        messageScrollView.frame = CGRect(x: messageScrollView.frame.origin.x, y: messageScrollView.frame.origin.y, width: messageScrollView.frame.width, height: view.frame.height - 100)
        // Sets original frame of toolbar
        toolBarOriginalFrame = inputToolBar.frame
        
//        print(messageScrollView.frame.height)
//        print(messageScrollView.contentSize.height)
//        print(messageScrollView.visibleSize.height)
        
        // Add notification observers for keyboard shown and hidden
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShows(aNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHides(aNotification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    // Move messageScrollView when skeyboard is shown
    @IBAction func keyboardShows(aNotification: NSNotification) {
        let kbSize = (aNotification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
        let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height + inputToolBar.frame.height - (view.frame.size.height - messageScrollView.frame.origin.y - messageScrollView.frame.size.height), right: 0.0)
        messageScrollView.contentInset = contentInset
        messageScrollView.scrollIndicatorInsets = contentInset
        inputToolBar.frame = CGRect(
            x: inputToolBar.frame.origin.x,
            y: inputToolBar.frame.origin.y - kbSize.height ,
            width: inputToolBar.frame.width,
            height: inputToolBar.frame.height)
        //messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum + 200)), animated: true)
    }
    
    // Move messageScrollView when keyboard is hidden
    @IBAction func keyboardHides(aNotification: NSNotification) {
        inputToolBar.frame = toolBarOriginalFrame
        
        let contentInsets = UIEdgeInsets.zero
        messageScrollView.contentInset = contentInsets
        messageScrollView.scrollIndicatorInsets = contentInsets
        messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
    }
    
     @IBAction func sendTapped(_ sender: Any) {
        send()
    }

    @IBAction func tapAction(_ sender: Any) {
        // Hide keyboard
        view.endEditing(true)
    }
    
    func prepareRequest() {
//        let request = ApiAI.shared().textRequest()
        print("Preparing request")
        
        // Define the URL to request to
        let userID = "12345"
//        guard let serverURL = URL(string: "https://info-med.herokuapp.com/api/faq/detectIntent/\(userID)") else { return }
        
//        let session = URLSession.shared
        
        // User's text input is valid
        if let text = tfInput.text {
//            request?.query = text // Put text from user input in the request
            let queryToSolve = Message(text: text, sender: "user")
            
            let getRequest = APIRequest(endpoint: "faq/detectIntent/\(userID)")
            
            getRequest.faq(queryToSolve, completion: { result in
                switch result {
                case .success(let response):
                    self.displayResponse(msg: response.fulfillmentText)
                    print("RESPUESTA :::: \(response.fulfillmentText)")
                case .failure(let error):
                    print("An error occured \(error).")
                }
            })
        }
        // text input is invalid
        else {
            return
        }
        
//        print("Executing request")
//        request?.setMappedCompletionBlockSuccess({ (request, response) in
//            let response = response as! AIResponse
//
//            // Display message if successful
//            if let textResponse = response.result.fulfillment.speech {
//                self.displayResponse(msg: textResponse)
//            }else{
//                print("There was an error")
//            }
//        }, failure: { (request, error) in
//            print(error!)
//        })
//
//        ApiAI.shared().enqueue(request)
//        tfInput.text = ""
        
    }
    
    func send(){
         if tfInput.text != ""{
            addBubble(bbl: Bubble(view: messageScrollView, msg: Message(text: tfInput.text!, sender: "user")))
            messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
            prepareRequest()
        }
        
        tfInput.text = ""
    }
    
    //MARK: - text field delegate implementations
    
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
    
    
