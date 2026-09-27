//
//  Item.swift
//  Dysgraphia App
//
//  Created by Prisha Mishra on 9/27/26.
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
