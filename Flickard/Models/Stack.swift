import Foundation
import SwiftData

@Model
class Stack {
    @Attribute(.unique)
    var id: UUID

    var name: String
    var isAIManaged: Bool = true
    var createdAt: Date = Date()
    var cardIDs: [UUID] = []
    var pendingRemovalCardIDs: [UUID] = []

    init(name: String, isAIManaged: Bool = true) {
        self.id = UUID()
        self.name = name
        self.isAIManaged = isAIManaged
    }

    /// Add a card to the stack. Deduplicates by default; set allowDuplicate for AI reinforcement.
    func addCard(_ id: UUID, allowDuplicate: Bool = false) {
        if allowDuplicate || !cardIDs.contains(id) {
            cardIDs.append(id)
        }
    }

    /// Add multiple cards (deduped)
    func addCards(_ ids: [UUID]) {
        for id in ids {
            addCard(id)
        }
    }

    /// Remove all occurrences of a card from both cardIDs and pendingRemovalCardIDs
    func removeCard(_ id: UUID) {
        cardIDs.removeAll { $0 == id }
        pendingRemovalCardIDs.removeAll { $0 == id }
    }

    /// Mark a card for removal (grayed out this session, removed next)
    func markForRemoval(_ id: UUID) {
        if !pendingRemovalCardIDs.contains(id) {
            pendingRemovalCardIDs.append(id)
        }
    }

    /// Called at the start of a new swipe session. Removes previously pending cards, then clears the pending list.
    func beginSession() {
        for id in pendingRemovalCardIDs {
            cardIDs.removeAll { $0 == id }
        }
        pendingRemovalCardIDs.removeAll()
    }

    /// Cards that are active (not pending removal) — used for filtering the deck
    var activeCardIDs: [UUID] {
        cardIDs.filter { !pendingRemovalCardIDs.contains($0) }
    }

    /// Check if a card is grayed out (pending removal)
    func isGrayedOut(_ id: UUID) -> Bool {
        pendingRemovalCardIDs.contains(id)
    }

    /// Number of unique cards in the stack
    var uniqueCardCount: Int {
        Set(cardIDs).count
    }
}
