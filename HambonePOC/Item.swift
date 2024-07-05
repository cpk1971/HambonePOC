//
//  Item.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-05.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
