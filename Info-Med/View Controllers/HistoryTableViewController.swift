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

class Poll {
    var name: String!
    var results = [String: Double]()
    
    init(name: String) {
        self.name = name
    }
    
    func append(symptom: String!, clinimetry: String!) {
        results[symptom] = Double(clinimetry)
    }
    
    func display() {
        print("Poll: \(name!)")
        print("Results:")
        for (key, val) in results {
            print("\(key) = \(val)")
        }
    }
}
//class HistoryCustomTableViewCell : UITableViewCell {
//
//
//}

class HistoryTableViewController: UITableViewController {
    
    // Variables
    var uid: String!
    
    // Reference of user collection
    var userCollectionRef: CollectionReference!
    
    var db: Any!
    var user: Any!
    var docID: String!
    var pollsList = [Poll]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        user = Auth.auth().currentUser
        
        userCollectionRef = Firestore.firestore().collection("users")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserAuth()
        getDataFromDB()
    }
    
    // MARK: - DATABASE QUERIES
    
    // Function to get email and uid of current user
    func getUserAuth() {
        let user = Auth.auth().currentUser
        if let user = user {
            uid = user.uid
        }
    }
    
    
    // Async func to fetch data from DB
    func getDataFromDB() {
        var docID : String!
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        
        // Query for the current user's document ID
        db.collection("users").whereField("uid", isEqualTo: user!.uid).getDocuments {(snapshot, error) in
            if let error = error {
                print("Error geting user document: \(error)")
                return
            }
            else {
                // Cycle to iterate over the user documents to get the document ID
                for collection in snapshot!.documents {
                    docID = collection.documentID
                    
                    // Query to get polls from user documents
                    db.collection("users").document(docID).collection("polls").getDocuments { (polls, error) in
                        if let err = error {
                            print("Error fetching polls: \(err)")
                            return
                        }
                        else {
                            
                            for poll in polls!.documents {
                                let pollObj = Poll(name: poll.documentID)
//                                print("\n\nCrea PollObj con nombre: \(poll.documentID)")
                                for (symptom, clinimetry) in poll.data() {
                                    pollObj.append(symptom: symptom, clinimetry: String(describing: clinimetry))
//                                    print("Agrega sintoma: \(symptom) = \(clinimetry)")
                                }
                                pollObj.display()
                                // Add poll to data structure
                                self.pollsList.append(pollObj)
                            }
                        }
                    }
                }
                // Reload data from table view
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
        
//
        
    }

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
