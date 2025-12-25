//
//  Item.swift
//  Chiffre
//
//  Created by zachmacmini on 2025/12/25.
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
