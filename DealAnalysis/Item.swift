//
//  Item.swift
//  DealAnalysis
//
//  Created by Karla Sosa on 3/15/25.
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
