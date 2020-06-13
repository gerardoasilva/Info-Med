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
    
}
