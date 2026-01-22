//
//  Untitled.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 21.01.26.
//
import SwiftData
import Combine
import SwiftUI

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
}

