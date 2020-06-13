//
//  DetailHistoryTableViewController.swift
//  Info-Med
//
//  Created by Gerardo Silva Razo on 28/05/20.
//  Copyright © 2020 Tecnológico de Monterrey. All rights reserved.
//

import UIKit

// Class of custom table view cell for detail history information
class DetailHistoryCustomTableViewCell: UITableViewCell {
    @IBOutlet weak var lbSymptom: UILabel!
    @IBOutlet weak var lbClinimetry: UILabel!
}

class DetailHistoryTableViewController: UITableViewController {
    // Variables
    var name: String!
    var poll: Poll!
    var arrSymptoms: [String]!
    var arrClinimetry: [Double]!
    var sortedKeys: [(key: String, value:Double)]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register custom heade cell
        tableView.register(TitleHeaderForTableView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        sortedKeys = poll.results.sorted(by: <)
    }

    // MARK: - Table view data source
    
    // Set table view header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    // Setup table view header content
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! TitleHeaderForTableView
        headerView.title.text = "Resultados"
        headerView.image.image = UIImage(named: "questionnaire.white")
        return headerView
    }

    // Set number of sections in table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Set number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sortedKeys.count
    }

    // Setup content for each cell of table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailHistoryCustomTableViewCell
        cell.lbSymptom.textColor = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
        cell.lbSymptom.text = sortedKeys[indexPath.row].key
        cell.lbClinimetry.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        cell.lbClinimetry.text = String(sortedKeys[indexPath.row].value)
        
        return cell
    }

}
