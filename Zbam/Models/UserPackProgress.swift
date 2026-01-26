import Foundation
import SwiftData

/// Tracks which cards from a content pack the user has added to their collection
@Model
class UserPackProgress {
    @Attribute(.unique)
    var packId: String

    var addedCardIds: [String]

    init(packId: String, addedCardIds: [String] = []) {
        self.packId = packId
        self.addedCardIds = addedCardIds
    }

    /// Check if a specific card has been added
    func hasAdded(cardId: String) -> Bool {
        addedCardIds.contains(cardId)
    }

    /// Mark a card as added
    func markAsAdded(cardId: String) {
        if !addedCardIds.contains(cardId) {
            addedCardIds.append(cardId)
        }
    }

    /// Mark multiple cards as added
    func markAsAdded(cardIds: [String]) {
        for cardId in cardIds {
            markAsAdded(cardId: cardId)
        }
    }

    /// Get the count of added cards
    var addedCount: Int {
        addedCardIds.count
    }
}
