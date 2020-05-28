//
//  MenuView.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 27/05/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class MenuView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    var reuseIdentifier = "cell"
    
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    var heightViewController: CGFloat! // height of view controller
    var messageScrollHeight: CGFloat!
    // Table data
    var labels: [String]!
    var icons: [UIImage?]!
    private var toolBarFrame: CGRect!
    private var scrollViewFrame: CGRect!
    
    // Declare notification for MenuOption of Questionnaire
    static let notificationOption = Notification.Name("sideMenuUserSelection")
    
    // Constructor for UIView subclass
    init(toolBarFrame: CGRect, scrollViewFrame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.toolBarFrame = toolBarFrame
        self.scrollViewFrame = scrollViewFrame
        setupViews()
        // Create sideMenu ViewController
        labels = [
            "Mi cuenta",
            "Preguntas COVID-19",
            "Cuestionario médico",
            "Historial",
            "",
            "Cerrar sesión"
        ]
        icons = [
            UIImage(named: "user")!,
            UIImage(named: "faq")!,
            UIImage(named: "questionnaire")!,
            UIImage(named: "history")!,
            nil,
            UIImage(named: "exit")
        ]
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SideMenuCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        //tableView Constrains
    }
    
    func setupViews() {
        let widthMenu = screenWidth/4*3
        
        heightViewController = UIScreen.main.bounds.height
        
        self.backgroundColor = .white
        // Shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
        tableView = UITableView(frame: CGRect(x: 0, y: scrollViewFrame.origin.y, width: widthMenu, height: screenHeight - scrollViewFrame.origin.y - toolBarFrame.height))
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        tableView.alwaysBounceVertical = false
        self.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        labels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SideMenuCell
        cell.descritionLabel.text = labels[indexPath.row]
        cell.iconImageView.image = icons[indexPath.row]
        
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 0.8470588235).withAlphaComponent(0.8)
        cell.selectedBackgroundView = view
        
        if indexPath.row == 4 {
            cell.isUserInteractionEnabled = false
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 4){
            let heightTableRows = tableView.rowHeight * 5
            return tableView.frame.height - heightTableRows
        }
        return 80;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Post notification depending on user selection
        if indexPath.row != 4 {
            switch indexPath.row {
            case 0:
                print("INFO tapped")
                // Post notification for user selection
                NotificationCenter.default.post(name: MenuView.notificationOption, object: MenuOption.info)
            case 1:
                print("FAQ tapped")
                // Post notification for user selection
                NotificationCenter.default.post(name: MenuView.notificationOption, object: MenuOption.faq)
            case 2:
                print("QUESTIONNAIRE tapped")
                // Post notification for user selection
                NotificationCenter.default.post(name: MenuView.notificationOption, object: MenuOption.questionnaire)
            case 3:
                print("HISTORY tapped")
                // Post notification for user selection
                NotificationCenter.default.post(name: MenuView.notificationOption, object: MenuOption.history)
            case 5:
                print("SIGNOUT tapped")
                // Post notification for user selection
                NotificationCenter.default.post(name: MenuView.notificationOption, object: MenuOption.signOut)
            default:
                print("Default")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
