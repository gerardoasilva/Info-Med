//
//  InfoViewController.swift
//  Info-Med
//
//  Created by user168608 on 5/26/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.frame.size.height = 100
        //self.view.frame.origin.y = 300
        // Do any additional setup after loading the view.
    }
    
    override func updateViewConstraints() {
        // distance to top introduced in iOS 13 for modal controllers
        // they're now "cards"
        /*
        let TOP_CARD_DISTANCE: CGFloat = 40.0
        
        // calculate height of everything inside that stackview
        var height: CGFloat = 0.0
        for v in self.stackView.subviews {
            height = height + v.frame.size.height
        }
 */
        
        // functional way of doing that, thanks to https://github.com/miguelangel-dev
        // var height: CGFloat = stackView.subviews.reduce(CGFloat(0.0), { result, v in result + v.frame.size.height })
        
        // change size of Viewcontroller's view to that height
        self.view.frame.size.height = 200
        // reposition the view (if not it will be near the top)
        self.view.frame.origin.y = 500
        // apply corner radius only to top corners
        //self.view.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        super.updateViewConstraints()
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
