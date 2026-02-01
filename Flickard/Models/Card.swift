import Foundation
import SwiftData

@Model
class Card: Identifiable {
    @Attribute(.unique)
    var id: UUID
    
    var front: String
    var back: String
    var lastSwipes: [String] = []
    var capacity: Int = 10 {
        didSet {
            if capacity < 1 { capacity = 1 }
            if lastSwipes.count > capacity {
                lastSwipes.removeFirst(lastSwipes.count - capacity)
            }
        }
    }
    
    init(front: String, back: String) {
        self.id = UUID()
        self.front = front
        self.back = back
    }
    
    func swipeRight() {
        lastSwipes.append("r")
        if (lastSwipes.count > capacity) {
            lastSwipes.removeFirst(lastSwipes.count - capacity)
        }
    }
    
    func swipeLeft() {
        lastSwipes.append("l")
        if (lastSwipes.count > capacity) {
            lastSwipes.removeFirst(lastSwipes.count - capacity)
        }
    }
}
