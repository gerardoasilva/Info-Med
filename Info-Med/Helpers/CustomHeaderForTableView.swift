//
//  CustomHeaderForTableView.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 28/05/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

// This class is fot the section header used in the table view
class CustomHeaderForTableView: UITableViewHeaderFooterView {
    let title = UILabel()
    let image = UIImageView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        image.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.backgroundColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 1)
        contentView.addSubview(image)
        contentView.addSubview(title)
        
        // Add style
//        image.tintColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        image.tintColor = .white
        
        title.textAlignment = .center
//        title.textColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        title.textColor = .white
        title.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        
        // Add constraints to elements
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            image.widthAnchor.constraint(equalToConstant: 40),
            image.heightAnchor.constraint(equalToConstant: 40),
            image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            title.topAnchor.constraint(equalTo: image.bottomAnchor)
        ])
        
    }
}
