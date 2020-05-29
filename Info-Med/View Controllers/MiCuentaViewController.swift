//
//  MiCuentaViewController.swift
//  Info-Med
//
//  Created by user168593 on 5/26/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class MyAccount: UIViewController {

    @IBOutlet var lbName: UILabel!
    @IBOutlet var lbMail: UILabel!
    @IBOutlet var lbNumber: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.preferredContentSize = CGSize(width: 100, height: 120)
    }
    
    
    @IBAction func returnAction(_ sender: Any) {

        dismiss(animated: true, completion: nil)
    }
    
}
