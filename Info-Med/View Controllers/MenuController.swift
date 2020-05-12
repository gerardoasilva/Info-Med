//
//  MenuController.swift
//  Info-Med
//
//  Created by user168593 on 5/12/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class MenuController: UIViewController {
    
    var table : UITableView!
    var reuseIdentifier = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(SideMenuCell.self, forCellReuseIdentifier: reuseIdentifier)
        table.backgroundColor = UIColor.lightGray
        table.separatorStyle = .none
        table.rowHeight = 80
        
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        table.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        table.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        //table.frame = 
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

extension MenuController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SideMenuCell
        return cell
    }
    
     
}
