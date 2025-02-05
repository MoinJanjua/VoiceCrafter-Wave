//
//  HistoryViewController.swift
//  VoiceCrafter Wave
//
//  Created by UCF 2 on 24/01/2025.
//

import UIKit

class HistoryViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var history = [TranslationHistory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let savedData = UserDefaults.standard.data(forKey: "TranslationHistory") {
               let decoder = JSONDecoder()
               do {
                   history = try decoder.decode([TranslationHistory].self, from: savedData)
               } catch {
                   print("Error decoding history: \(error.localizedDescription)")
               }
           }
        //noDataLabel.text = "No data found.Please add some data" // Set the message
        // Show or hide the table view and label based on data availability
        if history.isEmpty {
            TableView.isHidden = true
            noDataLabel.isHidden = false  // Show the label when there's no data
        } else {
            TableView.isHidden = false
            noDataLabel.isHidden = true   // Hide the label when data is available
        }
        // Check if data is loaded
        TableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! historyTableViewCell
        
        let rec = history[indexPath.item]
        cell.toCountry.text = "Translate From: \(rec.inputLanguage)"
        cell.toText.text = rec.inputText
        cell.fromCuntry.text = "Translate To: \(rec.outputLanguage)"
        cell.fromText.text = rec.outputText
        cell.datelb.text = rec.date
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 148
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from the RepairVehicle array
            history.remove(at: indexPath.row)
            
            // Update the UserDefaults
            let encoder = JSONEncoder()
            do {
                let updatedData = try history.map { try encoder.encode($0) }
                UserDefaults.standard.set(updatedData, forKey: "VehicleDetails")
            } catch {
                print("Error updating UserDefaults after deletion: \(error.localizedDescription)")
            }
            
            // Reload the table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Check if there's no data left
            if history.isEmpty {
                TableView.isHidden = true
                noDataLabel.isHidden = false
            }
        }
        
    }
    
    @IBAction func backbtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

