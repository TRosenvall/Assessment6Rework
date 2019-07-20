//
//  Entry.swift
//  Assessment6Rework
//
//  Created by Timothy Rosenvall on 7/20/19.
//  Copyright © 2019 Timothy Rosenvall. All rights reserved.
//

import Foundation

// Mark the class as Codable for persistence
class Entry: Codable {
    // Class Properties
    let name: String
    
    // Class Initializer
    init(name: String) {
        self.name = name
    }
}

// Set the class as equatable in order to allow deletion of entries.
extension Entry: Equatable {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.name == rhs.name
    }
}
