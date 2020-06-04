//
//  CreditsViewController.swift
//  Info-Med
//
//  Created by user168608 on 6/3/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {
    @IBOutlet weak var fingerHandle: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fingerHandle.layer.cornerRadius = fingerHandle.frame.size.height / 2
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
