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


class CustomTableViewCell : UITableViewCell {

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

    // Reference  of "users" collection
    var usersCollectionRef: CollectionReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Path to collection of users in Firebase
        usersCollectionRef = Firestore.firestore().collection("users")
        
        // Initialization of label names
        labels = [
                "Nombre",
                "Telefono",
                "Correo"
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        getUserAuth()
        getDbInformation()
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
    func getDbInformation() {

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
                        self.userInfo.append(self.phoneNumber)
                        self.userInfo.append(self.email)
                }
            }
            // Reload data from tableView after fetching data from DB
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.lbLabel.text = labels[indexPath.row]

    // Insert default value when data hasnt been fetched from DB
        if userInfo.isEmpty {
            cell.lbUserData.text = "Cargando..."
         }
        else {
            cell.lbUserData.text = userInfo[indexPath.row]
        }
        return cell
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

