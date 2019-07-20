//
//  PairRandomizerViewController.swift
//  Assessment6Rework
//
//  Created by Timothy Rosenvall on 7/20/19.
//  Copyright © 2019 Timothy Rosenvall. All rights reserved.
//

import UIKit

class PairRandomizerViewController: UIViewController {

    // Mark: - IBOutlets
    @IBOutlet weak var entriesTableView: UITableView!
    
    // Mark: - IBActions
    @IBAction func addNewEntryButtonTapped(_ sender: Any) {
        // Run the Alert Controller to add a new Entry
        addEntryAlertController()
    }
    
    @IBAction func randomizerButtonTapped(_ sender: Any) {
        // Run the randomize function
        EntryController.sharedInstance.randomizeEntries { (success) in
            if success {
                // If successful, update the tableView
                DispatchQueue.main.async{
                    self.entriesTableView.reloadData()
                }
            }
        }
    }
}

// Mark: - TableView Datasource and Delegate Extension
extension PairRandomizerViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Set the Section Header Label
        let label = UILabel()
        // Set the Label Text to the appropriate section heading.
        label.text = EntryController.sharedInstance.groups[section]
        // Set a background color to separate the sections from the cells in each section
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // The number of sections is the number of arrays in our array of arrays.
        return EntryController.sharedInstance.blockOfEntries.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of cells in each section is the number of entries in each sub array for our array of arrays.
        return EntryController.sharedInstance.blockOfEntries[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Setup each cell with the correct identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        // Pull each entry from the correct section and row.
        let entry = EntryController.sharedInstance.blockOfEntries[indexPath.section][indexPath.row]
        // Set the cell's title label to each entries name.
        cell.textLabel?.text = entry.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Check the correct editing style.
        if editingStyle == .delete {
            // Shortcut for the number of entries in the Source Of Truth
            let numberOfEntries = EntryController.sharedInstance.entries.count
            // Find the correct number of groups to have.
            let numberOfGroups = (numberOfEntries / 2) + (numberOfEntries % 2)
            // Pull each specific Entry out of the array of arrays.
            let entry = EntryController.sharedInstance.blockOfEntries[indexPath.section][indexPath.row]
            // Delete the correct Entry.
            EntryController.sharedInstance.deleteEntry(entry: entry, section: indexPath.section)
            // Check for the correct number of sections.
            if numberOfSections(in: entriesTableView) != numberOfGroups {
                // Delete the correct entry in each section.
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            // Reload the entriesTableView
            entriesTableView.reloadData()
        }
    }
}

// Mark: - Alert Controller Extension
extension PairRandomizerViewController: UITextFieldDelegate {
    
    // Alert Controller to add an Entry
    func addEntryAlertController () {
        // New UIAlertControllerInstance
        let alertController = UIAlertController(title: "Add Person", message: "Add someone new to the list.", preferredStyle: .alert)
        
        // Setup a textfield
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Full Name"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .words
            textField.delegate = self
        }
        
        // Setup an add button
        let addComment = UIAlertAction(title: "Add", style: .default) { (_) in
            // Check the textfield
            guard let entryText = alertController.textFields?.first?.text else {return}
            // If it's not empty
            if entryText != "" {
                // Create a new Entry from the textfield
                EntryController.sharedInstance.createEntry(name: entryText, completion: { (_) in
                    // Guard against race conditions
                    DispatchQueue.main.async {
                        self.entriesTableView.reloadData()
                    }
                })
            }
        }
        // Setup a cancel button
        let cancelAction = UIAlertAction(title:"Cancel", style: .cancel)
        
        // Add the buttons to the alertController
        alertController.addAction(addComment)
        alertController.addAction(cancelAction)
        // Present the alertController
        self.present(alertController, animated: true, completion: nil)
    }
}
