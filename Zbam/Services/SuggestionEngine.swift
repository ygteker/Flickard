import Foundation
import SwiftUI
import OSLog

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Engine that generates personalized card suggestions based on user's learning patterns
@MainActor
final class SuggestionEngine {
    static let shared = SuggestionEngine()

    /// Suggestion output with reasoning
    struct SuggestionResult {
        let cards: [PackCard]
        let reasoning: String
        let focusAreas: [String]
        let usedAI: Bool
    }

    /// User's learning profile derived from swipe history
    struct LearnerProfile {
        let totalSwipes: Int
        let rightSwipeRatio: Double
        let weakTags: [String]        // Tags where user struggles
        let strongTags: [String]      // Tags where user excels
        let currentLevel: DifficultyLevel
        let recentlyFailed: [String]  // Front text of recently failed cards

        var description: String {
            """
            Learning Profile:
            - Total swipes: \(totalSwipes)
            - Success rate: \(Int(rightSwipeRatio * 100))%
            - Current level: \(currentLevel.displayName)
            - Weak areas: \(weakTags.isEmpty ? "None identified" : weakTags.joined(separator: ", "))
            - Strong areas: \(strongTags.isEmpty ? "None identified" : strongTags.joined(separator: ", "))
            - Recently failed cards: \(recentlyFailed.count)
            """
        }
    }

    private init() {}

    // MARK: - Main Suggestion Generation

    /// Generate card suggestions based on user's learning patterns
    func generateSuggestions(
        userCards: [Card],
        availableCards: [PackCard],
        maxSuggestions: Int = 10
    ) async -> SuggestionResult {
        AppLogger.suggestions.info("Generating suggestions from \(availableCards.count) available cards")

        // Build learner profile
        let profile = buildLearnerProfile(from: userCards)
        AppLogger.suggestions.debug("Learner profile: \(profile.description)")

        // Try AI-powered suggestions on iOS 26+
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if let aiResult = await generateAISuggestions(
                profile: profile,
                availableCards: availableCards,
                maxSuggestions: maxSuggestions
            ) {
                AppLogger.suggestions.info("Generated \(aiResult.cards.count) AI-powered suggestions")
                return aiResult
            }
        }
        #endif

        // Fallback to heuristic suggestions
        let result = generateHeuristicSuggestions(
            profile: profile,
            availableCards: availableCards,
            maxSuggestions: maxSuggestions
        )
        AppLogger.suggestions.info("Generated \(result.cards.count) heuristic suggestions")
        return result
    }

    // MARK: - Learner Profile

    /// Analyze user's swipe history to build a learning profile
    func buildLearnerProfile(from cards: [Card]) -> LearnerProfile {
        var totalSwipes = 0
        var rightSwipes = 0
        let tagPerformance: [String: (right: Int, left: Int)] = [:]
        var recentlyFailed: [String] = []

        for card in cards {
            let swipes = card.lastSwipes
            totalSwipes += swipes.count

            for swipe in swipes {
                if swipe == "r" {
                    rightSwipes += 1
                }
            }

            // Analyze recent performance (last 3 swipes)
            let recentSwipes = swipes.suffix(3)
            let recentLeftCount = recentSwipes.filter { $0 == "l" }.count

            if recentLeftCount >= 2 {
                recentlyFailed.append(card.front)
            }
        }

        let rightRatio = totalSwipes > 0 ? Double(rightSwipes) / Double(totalSwipes) : 0.5

        // Determine current level based on performance
        let currentLevel: DifficultyLevel
        switch rightRatio {
        case 0..<0.4:
            currentLevel = .beginner
        case 0.4..<0.6:
            currentLevel = .elementary
        case 0.6..<0.75:
            currentLevel = .intermediate
        case 0.75..<0.85:
            currentLevel = .upperIntermediate
        case 0.85..<0.95:
            currentLevel = .advanced
        default:
            currentLevel = .mastery
        }

        // Extract weak and strong tags from tag performance
        let weakTags = tagPerformance
            .filter { $0.value.left > $0.value.right }
            .map { $0.key }

        let strongTags = tagPerformance
            .filter { $0.value.right > $0.value.left * 2 }
            .map { $0.key }

        return LearnerProfile(
            totalSwipes: totalSwipes,
            rightSwipeRatio: rightRatio,
            weakTags: weakTags,
            strongTags: strongTags,
            currentLevel: currentLevel,
            recentlyFailed: recentlyFailed
        )
    }

    // MARK: - AI-Powered Suggestions (iOS 26+)

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateAISuggestions(
        profile: LearnerProfile,
        availableCards: [PackCard],
        maxSuggestions: Int
    ) async -> SuggestionResult? {
        do {
            // Check if on-device AI is available by trying to get the default model
            let model = SystemLanguageModel.default
            guard model.isAvailable else {
                AppLogger.suggestions.info("Foundation Models not available on this device")
                return nil
            }

            let session = LanguageModelSession()

            // Build prompt with learner profile and available cards
            let cardsList = availableCards.prefix(50).map { card in
                "- ID: \(card.id), Front: \(card.front), Back: \(card.back), Tags: \(card.tags.joined(separator: ", "))"
            }.joined(separator: "\n")

            let prompt = """
            You are a language learning assistant. Based on the learner's profile, recommend which cards they should study next.

            \(profile.description)

            Available cards to choose from:
            \(cardsList)

            Select up to \(maxSuggestions) cards that would be most beneficial for this learner.
            Consider:
            1. Cards at an appropriate difficulty level
            2. Cards that address their weak areas
            3. A mix of topics for variety
            4. Cards that build on what they already know

            Respond with a JSON object containing:
            {
              "recommendedCardIds": ["id1", "id2", ...],
              "reasoning": "Brief explanation of why these cards were chosen",
              "focusCategories": ["category1", "category2"]
            }
            """

            let response = try await session.respond(to: prompt)
            let responseText = response.content

            // Parse the JSON response
            if let jsonStart = responseText.firstIndex(of: "{"),
               let jsonEnd = responseText.lastIndex(of: "}") {
                let jsonString = String(responseText[jsonStart...jsonEnd])
                if let data = jsonString.data(using: .utf8),
                   let parsed = try? JSONDecoder().decode(AIResponse.self, from: data) {

                    let recommendedCards = availableCards.filter { parsed.recommendedCardIds.contains($0.id) }

                    return SuggestionResult(
                        cards: recommendedCards,
                        reasoning: parsed.reasoning,
                        focusAreas: parsed.focusCategories,
                        usedAI: true
                    )
                }
            }

            AppLogger.suggestions.warning("Failed to parse AI response")
            return nil

        } catch {
            AppLogger.suggestions.error("AI suggestion error: \(error.localizedDescription)")
            return nil
        }
    }

    private struct AIResponse: Codable {
        let recommendedCardIds: [String]
        let reasoning: String
        let focusCategories: [String]
    }
    #endif

    // MARK: - Heuristic Suggestions (Fallback)

    private func generateHeuristicSuggestions(
        profile: LearnerProfile,
        availableCards: [PackCard],
        maxSuggestions: Int
    ) -> SuggestionResult {
        // Score each card based on heuristics
        var scoredCards: [(card: PackCard, score: Double)] = []

        for card in availableCards {
            var score = 0.0

            // 1. Difficulty match (higher score for appropriate difficulty)
            // For now, prefer beginner/elementary cards for new users
            if profile.totalSwipes < 50 {
                if card.tags.contains("basic") || card.tags.contains("essential") {
                    score += 3.0
                }
            }

            // 2. Tag relevance to weak areas
            for tag in card.tags {
                if profile.weakTags.contains(tag) {
                    score += 2.0 // Prioritize weak areas
                }
                if profile.strongTags.contains(tag) {
                    score -= 0.5 // Slightly deprioritize strong areas
                }
            }

            // 3. Variety bonus - add randomness for diverse suggestions
            score += Double.random(in: 0...1.5)

            // 4. Success rate adjustment
            if profile.rightSwipeRatio < 0.5 {
                // Struggling users get easier cards (prefer shorter words)
                if card.front.count < 15 {
                    score += 1.0
                }
            }

            scoredCards.append((card, score))
        }

        // Sort by score and take top suggestions
        let topCards = scoredCards
            .sorted { $0.score > $1.score }
            .prefix(maxSuggestions)
            .map { $0.card }

        // Generate reasoning
        var focusAreas: [String] = []
        var reasoning = "Based on your learning history"

        if profile.totalSwipes == 0 {
            reasoning = "Start with these foundational cards to build your vocabulary"
            focusAreas = ["basics", "common words"]
        } else if profile.rightSwipeRatio < 0.5 {
            reasoning = "Selected easier cards to help strengthen your foundation"
            focusAreas = ["review", "fundamentals"]
        } else if profile.rightSwipeRatio > 0.8 {
            reasoning = "You're doing great! Here are some new challenges"
            focusAreas = ["new vocabulary", "variety"]
        } else {
            reasoning = "A balanced mix of review and new material"
            if !profile.weakTags.isEmpty {
                focusAreas = Array(profile.weakTags.prefix(2))
            } else {
                focusAreas = ["vocabulary", "practice"]
            }
        }

        return SuggestionResult(
            cards: Array(topCards),
            reasoning: reasoning,
            focusAreas: focusAreas,
            usedAI: false
        )
    }
}
