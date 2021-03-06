//
//  SideMenuCell.swift
//  Info-Med
//
//  Created by user168593 on 5/12/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

// This is a class for the cells in the sideMenu
class SideMenuCell: UITableViewCell {
    
    
    // Create cell label
    let title: UILabel = { // Label constructor
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        label.font = UIFont(name: "Helvetica Neue", size: 20)
        label.text = ""
        return label
    }()
    
    // Crete an icon for this cell
    let iconImageView: UIImageView = { //construct icon
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1) // icon bgColor
        iv.clipsToBounds = true
        
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white // cell bgColor
        
        // Add icon sub view and center the icon to the left
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        // Add label sub view and center
        addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 12).isActive = true // Anchors to the right of the image
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
