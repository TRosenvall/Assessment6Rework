//
//  EntryController.swift
//  Assessment6Rework
//
//  Created by Timothy Rosenvall on 7/20/19.
//  Copyright © 2019 Timothy Rosenvall. All rights reserved.
//

import Foundation

class EntryController {
    // Mark: - Properties
    // Singleton
    static let sharedInstance = EntryController()
    
    // SourceOfTruth + Helper
    var blockOfEntries: [[Entry]] = []
    var entries: [Entry] = []
    var groups: [String] = []
    
    // Mark: - CRUD Functions
    // Create
    func createEntry (name: String, completion: @escaping (Bool) -> Void) {
        // Initialize a new Entry from the name property passed into it.
        let entry = Entry(name: name)
        // Append the initilized Entry to the Source Of Truth
        entries.append(entry)
        // Set the groups
        setGroups()
        setBlockOfEntries { (success) in
            // Save
            self.saveToPersistentStore()
            // Completion
            completion(success)
        }
    }
    
    func setGroups () {
        // Set a shortcut for the number of entries
        let numberOfEntries = self.entries.count
        // Pull an integer number of groups to have
        let numberOfGroups = numberOfEntries / 2 + numberOfEntries % 2
        // Check if the number of groups needs to be reset
        if self.groups.count != numberOfGroups && numberOfGroups != 0 {
            // Empty the groups array
            self.groups = []
            // Iterate through the number of groups needed and reset the groups.
            for group in 1...numberOfGroups {
                self.groups.append("Group \(group)")
            }
        }
    }
    
    // Setting up an array of arrays to hold the values for each section.
    func setBlockOfEntries (completion: @escaping (Bool) -> Void) {
        // Placeholder for the double array
        var entriesBlock: [[Entry]] = []
        // A helper array of Entries to be decremented from.
        var entriesHelper: [Entry] = self.entries
        // While the helper entry isn't entry.
        while entriesHelper.count > 0 {
            // Setup a dummy array for each spot in the entriesBlockArray.
            var newEntriesArray: [Entry] = []
            // Check each entry in the entriesHelper Array
            for entry in entriesHelper {
                // If the dummy array has less than two entries, append the Entries
                if newEntriesArray.count < 2 {
                    newEntriesArray.insert(entry, at: newEntriesArray.endIndex)
                }
            }
            // Remove the first two entries from the entriesHelper Array
            if entriesHelper.count > 1 {
                entriesHelper.remove(at: 0)
                entriesHelper.remove(at: 0)
            // If there is only one entry, remove it.
            } else if entriesHelper.count == 1 {
                entriesHelper.remove(at: 0)
            }
            // Insert the dummy array into the end position of the placeholder array of arrays.
            entriesBlock.insert(newEntriesArray, at: entriesBlock.endIndex)
            // Reset the dummy array.
            newEntriesArray = []
        }
        // Set the array of arrays to the placeholder array.
        self.blockOfEntries = entriesBlock
        // Return completion.
        completion(true)
    }
    
    // Read - Save and Load Functions
    func saveToPersistentStore() {
        // Set a JSON Encoder
        let jsonEncoder = JSONEncoder()
        
        do {
            // Encode the entries property
            let data = try jsonEncoder.encode(entries)
            // Write the encoded property to the correct URL
            try data.write(to: fileURL())
        } catch let error {
            // If we get an error, handle it.
            print("Error saving to persistent store: \(error.localizedDescription)")
        }
    }
    
    // This is run in the App Delegate
    func loadFromPersistentStore(completion: @escaping (Bool) -> Void) {
        // Set a JSON Decoder
        let jsonDecoder = JSONDecoder()
        
        do {
            // Pull the data out of the fileURL
            let data = try Data(contentsOf: fileURL())
            // Decode the JSON data
            let decodedEntries = try jsonDecoder.decode([Entry].self, from: data)
            // Set the Source Of Truth from the decoded data.
            self.entries = decodedEntries
            // Set the groups to the correct amount.
            setGroups()
            setBlockOfEntries { (success) in
                completion(success)
            }
        } catch let error {
            // If we get an error, handle it.
            print("Error loading from persistent store: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // Delete
    func deleteEntry (entry: Entry, section: Int) {
        // Find the index of the specific entry from the specific section in the array of arrays.
        guard let blockIndex = blockOfEntries[section].firstIndex(of: entry)
            else {return}
        // Find the index of the entry to remove and remove that entry.
        guard let entriesIndex = entries.firstIndex(of: entry) else {return}
        // Remove the index from the correct section.
        blockOfEntries[section].remove(at: blockIndex)
        // Remove from the Source Of Truth
        entries.remove(at: entriesIndex)
        // Check if there are any empty groups in the array of arrays.
        for entriesGroup in blockOfEntries {
            // If there are, remove that section.
            if entriesGroup.count == 0 {
                blockOfEntries.remove(at: section)
                // Reset the number of Groups.
                setGroups()
            }
        }
        // Update the save file.
        self.saveToPersistentStore()
    }
    
    // Mark: - URL Path For Persistance
    func fileURL() -> URL {
        // Pull the initial path where data will be stored.
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // Get the folder in which the data will be saved.
        let documentDirectory = paths[0]
        // Choose what the file will be called.
        let fileName = "entries.json"
        // Set the URL to the full path and file name
        let url = documentDirectory.appendingPathComponent(fileName)
        // Return the URL
        return url
    }
    
    // Mark: - Randomizer Function
    func randomizeEntries (completion: @escaping (Bool) -> Void) {
        // Setup a variable array equal to the Source Of Truth
        var entriesToRandomize = self.entries
        // Setup a variable to hold the randomized Entries.
        var entriesRandomized: [Entry] = []
        // Go until the entriesToRandomize array is empty
        while entriesToRandomize.count != 0 {
            // Generate a random integer between 0 and the number of entriesToRandomize array
            let randomEntryIndex = Int.random(in: 0...entriesToRandomize.count-1)
            // Append that entry to the entriesRandomized array
            entriesRandomized.append(entriesToRandomize[randomEntryIndex])
            // Pull that entry from the entriesToRandomize array
            entriesToRandomize.remove(at: randomEntryIndex)
        }
        // Reset the Source Of Truth to the new randomized entries array.
        self.entries = entriesRandomized
        setBlockOfEntries { (success) in
            completion(success)
        }
    }
}
