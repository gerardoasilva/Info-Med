//
//  PasswordViewController.swift
//  Info-Med
//
//  Created by user168608 on 5/28/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {
    
    @IBOutlet weak var tfCurrentPassword: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func pressSaveChanges(_ sender: UIButton) {
        
    }
    
    @IBAction func pressCancel(_ sender: UIButton) {
        
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
