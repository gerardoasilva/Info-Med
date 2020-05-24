//
//  MenuController.swift
//  Info-Med
//
//  Created by user168593 on 5/12/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

protocol menuOption  {
    func clickOption() -> Void
}

class MenuController: UIViewController {
    
    var table : UITableView!
    var reuseIdentifier = "cell"
    
    //table data
    var labels : [String]!
    var icons : [UIImage]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize table
        table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(SideMenuCell.self, forCellReuseIdentifier: reuseIdentifier) //register cells of type SideMenuCell using reuse identifier
        table.backgroundColor = .white
        table.separatorStyle = .none
        table.rowHeight = 80
        
        view.addSubview(table)
        //tableView Constrains
        table.translatesAutoresizingMaskIntoConstraints = false
        table.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        table.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        table.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        //initialize table data
        labels = ["Mi cuenta", "Bot Covid-19", "Cuestionario médico", "Historial"]
        icons = [UIImage(systemName: "person.fill")!, UIImage(systemName: "bubble.left.fill")!, UIImage(systemName: "doc.text.magnifyingglass")!, UIImage(systemName: "tray.full.fill")!]
    }
}

extension MenuController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        labels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SideMenuCell
        cell.descritionLabel.text = labels[indexPath.row]
        cell.iconImageView.image = icons[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Finish segue implementation here
        switch indexPath.row {
        case 0:
            print("Ir a mi cuenta")
        case 1:
            print("Ir a bot covid")
        case 2:
            print("Ir a Historial")
        default:
            print("Default")
        }
    }
     
}
