//
//  Untitled.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 21.01.26.
//
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

