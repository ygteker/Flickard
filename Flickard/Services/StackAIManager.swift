import Foundation
import SwiftData
import OSLog

/// Analyzes completed swipe sessions and manages stack card lifecycle (AI-driven additions/removals)
@MainActor
final class StackAIManager {
    static let shared = StackAIManager()
    private init() {}

    /// Result summary from session analysis
    struct SessionResult {
        let cardsAdded: Int
        let cardsDuplicated: Int
        let cardsMastered: Int
    }

    /// Analyze a completed swipe session and update the stack accordingly.
    /// - Parameters:
    ///   - stack: The stack being studied
    ///   - swipeResults: Array of (cardID, direction) from the session
    ///   - context: SwiftData model context for fetching/inserting cards
    func analyzeSession(
        stack: Stack,
        swipeResults: [(UUID, CardView.SwipeDirection)],
        context: ModelContext
    ) async -> SessionResult {
        guard stack.isAIManaged else {
            AppLogger.stacks.info("Stack '\(stack.name)' is not AI-managed, skipping analysis")
            return SessionResult(cardsAdded: 0, cardsDuplicated: 0, cardsMastered: 0)
        }

        AppLogger.stacks.info("Analyzing session for stack '\(stack.name)' with \(swipeResults.count) swipes")

        // Build per-card swipe history from this session
        var sessionSwipes: [UUID: [CardView.SwipeDirection]] = [:]
        for (cardId, direction) in swipeResults {
            sessionSwipes[cardId, default: []].append(direction)
        }

        // Fetch all user cards to check lastSwipes history
        let allCards: [Card]
        do {
            allCards = try context.fetch(FetchDescriptor<Card>())
        } catch {
            AppLogger.stacks.error("Failed to fetch cards: \(error.localizedDescription)")
            return SessionResult(cardsAdded: 0, cardsDuplicated: 0, cardsMastered: 0)
        }

        let cardMap = Dictionary(uniqueKeysWithValues: allCards.map { ($0.id, $0) })

        // Identify struggling cards: 2+ left swipes in last 3 swipes
        var strugglingCardIDs: [UUID] = []
        // Identify mastered cards: 4+ consecutive right swipes
        var masteredCardIDs: [UUID] = []

        let uniqueCardIDs = Set(swipeResults.map { $0.0 })
        for cardId in uniqueCardIDs {
            guard let card = cardMap[cardId] else { continue }
            let lastSwipes = card.lastSwipes

            // Check struggling: last 3 swipes have 2+ lefts
            let recentSwipes = lastSwipes.suffix(3)
            let leftCount = recentSwipes.filter { $0 == "l" }.count
            if leftCount >= 2 {
                strugglingCardIDs.append(cardId)
            }

            // Check mastery: 4+ consecutive right swipes at the end
            let consecutiveRights = lastSwipes.reversed().prefix(while: { $0 == "r" }).count
            if consecutiveRights >= 4 {
                masteredCardIDs.append(cardId)
            }
        }

        AppLogger.stacks.info("Struggling: \(strugglingCardIDs.count), Mastered: \(masteredCardIDs.count)")

        // Handle struggling cards
        var totalAdded = 0
        var totalDuplicated = 0

        for cardId in strugglingCardIDs {
            // Duplicate the struggling card in the stack for reinforcement
            stack.addCard(cardId, allowDuplicate: true)
            totalDuplicated += 1
        }

        // Add related pack cards for struggling cards
        if !strugglingCardIDs.isEmpty {
            let strugglingCards = strugglingCardIDs.compactMap { cardMap[$0] }
            totalAdded += await addRelatedCards(
                for: strugglingCards,
                to: stack,
                allUserCards: allCards,
                context: context
            )
        }

        // Handle mastered cards
        for cardId in masteredCardIDs {
            stack.markForRemoval(cardId)
        }

        do {
            try context.save()
        } catch {
            AppLogger.stacks.error("Failed to save after session analysis: \(error.localizedDescription)")
        }

        let result = SessionResult(
            cardsAdded: totalAdded,
            cardsDuplicated: totalDuplicated,
            cardsMastered: masteredCardIDs.count
        )

        AppLogger.stacks.info("Session result: added=\(result.cardsAdded), duplicated=\(result.cardsDuplicated), mastered=\(result.cardsMastered)")
        return result
    }

    /// Add related pack cards for struggling cards using SuggestionEngine
    private func addRelatedCards(
        for strugglingCards: [Card],
        to stack: Stack,
        allUserCards: [Card],
        context: ModelContext
    ) async -> Int {
        // Get all available pack cards
        let availableCards: [PackCard]
        do {
            let progressDescriptor = FetchDescriptor<UserPackProgress>()
            let allProgress = try context.fetch(progressDescriptor)
            let progressMap = Dictionary(uniqueKeysWithValues: allProgress.map { ($0.packId, $0) })
            availableCards = try await ContentPackLoader.shared.getAllUnaddedCards(progressMap: progressMap)
        } catch {
            AppLogger.stacks.error("Failed to load available pack cards: \(error.localizedDescription)")
            return 0
        }

        guard !availableCards.isEmpty else {
            AppLogger.stacks.info("No available pack cards to add")
            return 0
        }

        // Use SuggestionEngine to find related cards (limit to 4)
        let suggestions = await SuggestionEngine.shared.generateSuggestions(
            userCards: allUserCards,
            availableCards: availableCards,
            maxSuggestions: 4
        )

        guard !suggestions.cards.isEmpty else {
            AppLogger.stacks.info("SuggestionEngine returned no suggestions")
            return 0
        }

        // Convert pack cards to user cards, insert into SwiftData, add to stack
        var addedCount = 0
        for packCard in suggestions.cards {
            let card = packCard.toCard()
            context.insert(card)

            // Update pack progress
            do {
                let store = CardStore(context: context)
                let progress = try store.getOrCreateProgress(for: packCard.packId)
                progress.markAsAdded(cardId: packCard.id)
            } catch {
                AppLogger.stacks.error("Failed to update pack progress: \(error.localizedDescription)")
            }

            stack.addCard(card.id)
            addedCount += 1
        }

        AppLogger.stacks.info("Added \(addedCount) related cards to stack '\(stack.name)'")
        return addedCount
    }
}
