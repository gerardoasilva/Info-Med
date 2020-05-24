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

class MenuController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var table : UITableView!
    var reuseIdentifier = "cell"
    
    var heightViewController: CGFloat! // height of view controller
    
    //table data
    var labels : [String]!
    var icons : [UIImage?]!
    var heightToolbar: CGFloat!
    
    init(labels: [String], icons: [UIImage?], heightToolbar: CGFloat) {
        self.labels = labels
        self.icons = icons
        self.heightToolbar = heightToolbar
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // height of view controller
        heightViewController = self.view.frame.size.height
        print("heightViewController: ",heightViewController!)
        
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
//        labels = ["Mi cuenta", "Bot Covid-19", "Cuestionario médico", "Historial"]
//        icons = [UIImage(systemName: "person.fill")!, UIImage(systemName: "bubble.left.fill")!, UIImage(systemName: "doc.text.magnifyingglass")!, UIImage(systemName: "tray.full.fill")!]
    }
    
    /*
     *  Height of status bar + navigation bar (if navigation bar exist)
    */
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
                (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        labels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SideMenuCell
        cell.descritionLabel.text = labels[indexPath.row]
        cell.iconImageView.image = icons[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //table.rowHeight
        if (indexPath.row == 4){
            print("barH: ", topbarHeight)
            print("toolH: ", heightToolbar ?? 0.0)
            return heightViewController - (table.rowHeight * 5) - heightToolbar - topbarHeight
        }
        return 80;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Finish segue implementation here
        switch indexPath.row {
        case 0:
            print("Ir a mi cuenta")
        case 1:
            print("Ir a bot covid")
        case 2:
            print("Ir a Cuestionario médico")
        case 3:
            print("Ir a Historial")
        case 4:
            print("Empty")
        default:
            print("Default")
        }
    }
}
