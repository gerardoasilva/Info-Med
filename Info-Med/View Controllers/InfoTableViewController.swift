//
//  InfoTableViewController.swift
//  Info-Med
//
//  Created by user168608 on 5/26/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

// Class for custom cells used in table view of userInfo
class UserInfoCustomTableViewCell : UITableViewCell {
    @IBOutlet weak var lbLabel: UILabel!
    @IBOutlet weak var lbUserData: UILabel!
}

class InfoTableViewController: UITableViewController {
    
    // Array for user information
    var userInfo = [String]()
    
    // Array for name of labels
    var labels: [String]!
    
    // User information variables
    var email: String!
    var uid: String!
    var firstName: String!
    var lastName: String!
    var phoneNumber: String!
    var password: String = "Cambia tu contraseña"
    
    // Reference of "users" collection
    var usersCollectionRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register custom header view
        tableView.register(TitleHeaderForTableView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        configureNavBar()
        
        // Path to collection of users in Firebase
        usersCollectionRef = Firestore.firestore().collection("users")
        
        // Initialization of label names
        labels = [
            "Nombre",
            "Correo electrónico",
            "Teléfono",
            "Contraseña"
        ]
        
        // Add gesture recognizer to go back
        let backPanEdgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(goBack))
        self.view.addGestureRecognizer(backPanEdgeGesture)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserAuth()
        getDataFromDB()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .none
    }
    
    // Function to add navbar style
    func configureNavBar(){
        
        // Make navbar transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        // Style for pushed view controller's nav bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.05835793167, green: 0.624536097, blue: 0.9605233073, alpha: 1)
        
    }
    
    // Function to go to previous view conotroller
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // Function to get email and uid of current user
    func getUserAuth() {
        let user = Auth.auth().currentUser
        if let user = user {
            email = user.email ?? ""
            uid = user.uid
        }
    }
    
    // Asynchronous query to get information from DB
    func getDataFromDB() {
        
        // Get documents found in "users" collection
        usersCollectionRef.getDocuments { (snapshot, error) in
            
            if let err = error{
                print("Error fetching user documents: \(err)")
            } else {
                
                guard let snap = snapshot else { return }
                
                // Iterate through all documents
                for document in (snap.documents) {
                    
                    // Save each document content
                    let data = document.data()
                    
                    // Get uid of user in current document
                    let dbUid = data["uid"] as? String ?? "-"
                    
                    // Check for uid of current user
                    if dbUid == self.uid {
                        
                        // Iterate through user data
                        for (key, value) in data {
                            
                            if key == "firstName" {
                                self.firstName = String(describing: value)
                            }
                            else if key == "lastName" {
                                self.lastName = String(describing: value)
                            }
                            else if key == "phoneNumber" {
                                self.phoneNumber = String(describing: value)
                            }
                        }
                        // Insert user information in array
                        let fullName = self.firstName + " " + self.lastName
                        self.userInfo.append(fullName)
                        self.userInfo.append(self.email)
                        self.userInfo.append(self.phoneNumber)
                        self.userInfo.append(self.password)
                    }
                }
                // Reload data from tableView after fetching data from DB
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - TABLE VIEW DATA SOURCE
    
    // Set the height of table view header
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    // Set content of table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! TitleHeaderForTableView
        headerView.title.text = "Información personal"
        headerView.image.image = UIImage(systemName: "person.crop.circle")
        return headerView
    }
    
    // Set number of sections in table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set number of rows in table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    // Style each row and add content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserInfoCustomTableViewCell
        // Style
        cell.lbLabel.textColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        cell.lbLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        
        cell.lbUserData.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cell.lbUserData.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        
        cell.isUserInteractionEnabled = false
        
        cell.lbLabel.text = labels[indexPath.row]
        
        if indexPath.row == 3 {
            cell.accessoryType = .disclosureIndicator
            cell.isUserInteractionEnabled = true
        }
        
        // Insert default value when data hasnt been fetched from DB
        if userInfo.isEmpty {
            cell.lbUserData.text = "Cargando..."
        }
        else {
            cell.lbUserData.text = userInfo[indexPath.row]
        }
        return cell
    }
    
    // Go to password view controller if cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 3) {
            let passwordViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.passwordViewController) as? PasswordViewController
            self.navigationController?.pushViewController(passwordViewController!, animated: true)
        }
    }
    
}
