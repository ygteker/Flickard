//
//  Card.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 16.01.26.
//

import Foundation
import SwiftData

@Model
class Card: Identifiable {
    var id: UUID
    var front: String
    var back: String
    
    init(front: String, back: String) {
        self.id = UUID()
        self.front = front
        self.back = back
        
    }
}
