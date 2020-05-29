//
//  HistoryTableViewController.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 28/05/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase


//class HistoryCustomTableViewCell : UITableViewCell {
//
//
//}

class HistoryTableViewController: UITableViewController {
    
    // Variables
    var uid: String!
    
    // Reference of user collection
    var userCollectionRef: CollectionReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userCollectionRef = Firestore.firestore().collection("users")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserAuth()
//        getDataFromDB()
    }
    
    // MARK: - DATABASE QUERIES
    
    // Function to get email and uid of current user
    func getUserAuth() {
        let user = Auth.auth().currentUser
        if let user = user {
            uid = user.uid
        }
    }
    
    
//    // Async func to fetch data from DB
//    func getDataFromDB() {
//
//        userCollectionRef.getDocuments { (snapshot, error) in
//
//                if let err = error{
//                print("Error fetching user documents: \(err)")
//                } else {
//
//                    guard let snap = snapshot else { return }
//
//                    // Iterate through all documents
//                    for document in (snap.documents) {
//
//                        // Save each document content
//                        let data = document.data()
//
//                        // Get uid of user in current document
//                        let dbUid = data["uid"] as? String ?? "-"
//
//                            // Check if it is the user we are looking for
//                            if dbUid == self.uid {
//
//                                // Iterate through user data
//                                for (key, value) in data {
//
//                                    if key == "firstName" {
//                                        self.firstName = String(describing: value)
//                                    }
//                                    else if key == "lastName" {
//                                        self.lastName = String(describing: value)
//                                    }
//                                    else if key == "phoneNumber" {
//                                        self.phoneNumber = String(describing: value)
//                                }
//                            }
//                                // Insert user information in array
//                                let fullName = self.firstName + " " + self.lastName
//                                self.userInfo.append(fullName)
//                                self.userInfo.append(self.email)
//                                self.userInfo.append(self.phoneNumber)
//                                self.userInfo.append(self.password)
//                                }
//                    }
//                    // Reload data from tableView after fetching data from DB
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                }
//        }
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // REVISAR............
        // Cambiar a que cada sección sea una fecha?????
        // Si el usuario hizo 3 cuestionarios el mismo día que sean tres rows de una misma sección???
        // REVISAR............
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
