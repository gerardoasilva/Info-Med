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

class HistoryTableViewController: UITableViewController {
    
    // Variables
    var uid: String!
    
    // Reference of user collection
    var userCollectionRef: CollectionReference!
    
    var db: Any!
    var user: Any!
    var docID: String!
    var pollsList = [Poll]()
    
    // Initialize variables and setup elements
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        user = Auth.auth().currentUser
        
        userCollectionRef = Firestore.firestore().collection("users")
        
        // Register custom header view
        tableView.register(TitleHeaderForTableView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserAuth()
        getDataFromDB { (status) in
            if status {
                self.tableView.reloadData()
            }
        }
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
    func getDataFromDB(completion: @escaping (_ status: Bool) -> Void) {
        var docID : String!
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        
        // Query for the current user's document ID
        db.collection("users").whereField("uid", isEqualTo: user!.uid).getDocuments {(snapshot, error) in
            if let error = error {
                print("Error geting user document: \(error)")
                completion(false)
            }
            else {
                // Cycle to iterate over the user documents to get the document ID
                for collection in snapshot!.documents {
                    docID = collection.documentID
                    
                    // Query to get polls from user documents
                    db.collection("users").document(docID).collection("polls").getDocuments { (polls, error) in
                        if let err = error {
                            print("Error fetching polls: \(err)")
                            completion(false)
                        }
                        else {
                            
                            for poll in polls!.documents {
                                let pollObj = Poll(name: poll.documentID)
                                
                                for (symptom, clinimetry) in poll.data() {
                                    pollObj.append(symptom: symptom, clinimetry: String(describing: clinimetry))
                                }
                                // Add poll to data structure
                                self.pollsList.append(pollObj)
                            }
                            
                            // Reload data from table view
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        }
                    }
                }
                completion(true)
            }
        }
    }

    // MARK: - Table view data source
    
    // Set table view header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    // Setup header content
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! TitleHeaderForTableView
        headerView.title.text = "Historial"
        headerView.image.image = UIImage(named: "history.white")
        return headerView
    }
    
    // Set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Set number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pollsList.count
    }

    // Setup row content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Parse string name from poll
        let dateArr = self.pollsList[indexPath.row].name.components(separatedBy: " ")
        
        cell.textLabel?.text = "Cuestionario \(indexPath.row+1)"
        cell.detailTextLabel?.text = "\(dateArr[2])/\(dateArr[1])/\(dateArr[0])"
        
        if dateArr.isEmpty {
            cell.detailTextLabel?.text = "Cargando..."
        }
        else {
            cell.detailTextLabel?.text = "\(dateArr[2])/\(dateArr[1])/\(dateArr[0])"
        }
        return cell
    }
    
    // Remove selection style of row when pressed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailView = segue.destination as! DetailHistoryTableViewController
        let indexPath = tableView.indexPathForSelectedRow!
        
        detailView.poll = pollsList[indexPath.row] 
    }

}
