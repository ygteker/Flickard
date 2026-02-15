import SwiftData
import Combine
import SwiftUI
import OSLog

@MainActor
@Observable
final class CardStore: ObservableObject {
    let context: ModelContext
    init (context: ModelContext) {
        self.context = context
    }
    
    func card(id: UUID) throws -> Card? {
        let fd = FetchDescriptor<Card>(predicate: #Predicate { $0.id == id })
        return try context.fetch(fd).first
    }
    
    func addCard(cardId: UUID, front: String, back: String) throws {
        guard let card = try card(id: cardId) else { return }
        context.insert(card)
        try context.save()
    }
    
    func swipe(cardId: UUID, direction: CardView.SwipeDirection) {
        do {
            guard let card = try self.card(id: cardId) else { return }
            if direction == .right {
                card.swipeRight()
            } else {
                card.swipeLeft()
            }
            try context.save()
        } catch {
            // handle error
        }
    }
    
    func getAllCards() throws -> [Card] {
        return try context.fetch(FetchDescriptor<Card>())
    }

    /// Add multiple cards from a pack in a single transaction
    func addCardsFromPack(_ packCards: [PackCard], progress: UserPackProgress) throws {
        for packCard in packCards {
            let card = packCard.toCard()
            context.insert(card)
            progress.markAsAdded(cardId: packCard.id)
        }
        try context.save()
        AppLogger.packs.info("Bulk added \(packCards.count) cards from pack")
    }

    /// Add a single card from a pack and update progress
    func addCardFromPack(_ packCard: PackCard, progress: UserPackProgress) throws {
        let card = packCard.toCard()
        context.insert(card)
        progress.markAsAdded(cardId: packCard.id)
        try context.save()
        AppLogger.packs.info("Added card \(packCard.id) from pack \(packCard.packId)")
    }

    /// Fetch cards by a set of UUIDs
    func cards(ids: Set<UUID>) throws -> [Card] {
        let allCards = try context.fetch(FetchDescriptor<Card>())
        return allCards.filter { ids.contains($0.id) }
    }

    /// Delete a card and remove it from all stacks
    func deleteCardAndCleanStacks(_ card: Card) throws {
        let cardId = card.id
        let stacks = try context.fetch(FetchDescriptor<Stack>())
        for stack in stacks {
            stack.removeCard(cardId)
        }
        context.delete(card)
        try context.save()
        AppLogger.stacks.info("Deleted card \(cardId) and cleaned from \(stacks.count) stacks")
    }

    /// Get or create a UserPackProgress for a given pack ID
    func getOrCreateProgress(for packId: String) throws -> UserPackProgress {
        let descriptor = FetchDescriptor<UserPackProgress>(
            predicate: #Predicate { $0.packId == packId }
        )
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let newProgress = UserPackProgress(packId: packId)
        context.insert(newProgress)
        return newProgress
    }
}

