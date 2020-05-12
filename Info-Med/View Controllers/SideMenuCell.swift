//
//  SideMenuCell.swift
//  Info-Med
//
//  Created by user168593 on 5/12/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    let descritionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Sample" //test sample text
        return label
    }()
    
    //crete an icon for this cell
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        
        iv.backgroundColor = .blue //test color for visualization
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .darkGray
                
        //add icon sub view and center the icon to the left
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        //add lable sub view
        addSubview(descritionLabel)
        descritionLabel.translatesAutoresizingMaskIntoConstraints = false
        descritionLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        descritionLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 12).isActive = true //anchors to the right of the image
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
