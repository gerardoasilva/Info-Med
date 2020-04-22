//
//  ChatViewController.swift
//  Info-Med
//
//  Created by user168593 on 4/21/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
// something

import UIKit
import ApiAI
import AVFoundation

class ChatViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var messageScrollView: UIScrollView!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var btSend: UIButton!
    
    var activeField : UITextField!
    
    var aBubble : Bubble!
    var bubblesList : [Bubble]!
    var acumulatedHeight = 0
    var offsetAccum = 0
    
    let speechSynthesizer = AVSpeechSynthesizer()

    func displayResponse(msg: String) {
        print("Request completed")
        /*let speechUtterance = AVSpeechUtterance(string: msg)
        speechSynthesizer.speak(speechUtterance)*/
        
        //if tfInput.text != ""{
        addBubble(bbl: Bubble(view : messageScrollView, msg : Message(sender: "agent", text: msg)))
        messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
    }
    
    func addBubble(bbl : Bubble){
        if bubblesList == nil{
            bubblesList = [bbl]
        }else{
            bubblesList.append(bbl)
        }
        
        let addedHeight = Int(bbl.frame.height) + bbl.padd
        bbl.setY(y: CGFloat(acumulatedHeight + bbl.padd))
        acumulatedHeight += addedHeight
        messageScrollView.addSubview(bbl)
        messageScrollView.contentSize.height = CGFloat(acumulatedHeight + bbl.padd)
        
        if CGFloat(acumulatedHeight + bbl.padd) > messageScrollView.frame.height{
            offsetAccum += addedHeight
        }
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfInput.delegate = self
        self.tfInput.returnKeyType = UIReturnKeyType.send
        messageScrollView.isScrollEnabled = true
        
        aBubble = Bubble(view : messageScrollView, msg : Message(sender: "bot", text: "Lorem Ipsum wjnbdvagjhfcwdjvkblwaklnkbhdvjghcgwxadhgvjbhwkjkdnbavhcfdhgwjhdbaghfcwhdghwabdvawchdhwjbdavhgwvjabwhvgdhcwvjahbdjg"))
        addBubble(bbl: aBubble)
        
        //registers for  keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoSeMostro(aNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoSeOculto(aNotification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @IBAction func tecladoSeMostro(aNotification: NSNotification) {
        let kbSize = (aNotification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
        let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height - (view.frame.size.height - messageScrollView.frame.origin.y - messageScrollView.frame.size.height), right: 0.0)
        messageScrollView.contentInset = contentInset
        messageScrollView.scrollIndicatorInsets = contentInset
        //messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum + 200)), animated: true)
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    @IBAction func tecladoSeOculto(aNotification : NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        messageScrollView.contentInset = contentInsets
        messageScrollView.scrollIndicatorInsets = contentInsets
        messageScrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(offsetAccum)), animated: true)
    }
    
    @IBAction func actSend(_ sender: Any) {
        send()
    }

    @IBAction func tapAction(_ sender: Any) {
        view.endEditing(true)
    }
    
    func prepareRequest() {
        let request = ApiAI.shared().textRequest()
        print("preparing Request")
        //Validaton of text
        if let text = tfInput.text, text != "" {
            
            // Put text from user input in the request
            request?.query = text
        } else {
            return
        }
        
        print("executing request")
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse

            // Display message if successful
            if let textResponse = response.result.fulfillment.speech {
                self.displayResponse(msg: textResponse)
            }else{
                print("some weird error")
            }
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
        tfInput.text = ""
        
    }
    
    func send(){
         if tfInput.text != ""{
            addBubble(bbl: Bubble(view : messageScrollView, msg : Message(sender: "user", text: tfInput.text!)))
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
    func textFieldDidBeginEditing (_ textField : UITextField )
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing (_ textField : UITextField )
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
    
    
