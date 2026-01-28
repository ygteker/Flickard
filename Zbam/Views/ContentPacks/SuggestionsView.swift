import SwiftUI
import SwiftData
import OSLog

/// AI-powered personalized card suggestions view
struct SuggestionsView: View {
    let allCards: [Card]
    let packProgress: [UserPackProgress]

    @Environment(\.modelContext) private var modelContext
    @StateObject private var loader = ContentPackLoader.shared
    private var engine: SuggestionEngine { SuggestionEngine.shared }
    @State private var suggestions: SuggestionEngine.SuggestionResult?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedCard: PackCard?

    private var progressMap: [String: UserPackProgress] {
        Dictionary(uniqueKeysWithValues: packProgress.map { ($0.packId, $0) })
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Analyzing your learning patterns...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(error)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await generateSuggestions()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                Spacer()
            } else if let result = suggestions {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // AI badge and reasoning
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: result.usedAI ? "brain" : "lightbulb.fill")
                                    .foregroundStyle(result.usedAI ? .purple : .yellow)
                                    .accessibilityHidden(true)
                                Text(result.usedAI ? "AI Suggestions" : "Smart Suggestions")
                                    .font(.headline)

                                Spacer()

                                Button {
                                    Task {
                                        await generateSuggestions()
                                    }
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.subheadline)
                                }
                                .accessibilityLabel("Refresh suggestions")
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.circle)
                            }

                            Text(result.reasoning)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if !result.focusAreas.isEmpty {
                                HStack(spacing: 8) {
                                    Text("Focus areas:")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    ForEach(result.focusAreas, id: \.self) { area in
                                        Text(area)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.accentColor.opacity(0.15))
                                            .foregroundStyle(Color.accentColor)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        if result.cards.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.green)
                                    .accessibilityHidden(true)
                                Text("You've added all available cards!")
                                    .font(.headline)
                                Text("Check back later for new content packs.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            // Suggested cards
                            Text("Recommended for you")
                                .font(.headline)
                                .padding(.top, 8)
                                .accessibilityAddTraits(.isHeader)

                            ForEach(result.cards) { card in
                                Button {
                                    selectedCard = card
                                } label: {
                                    SuggestionCardRow(card: card)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)
                    Text("No suggestions yet")
                        .font(.headline)
                    Text("Start swiping some cards to get personalized suggestions!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            }
        }
        .task {
            await generateSuggestions()
        }
        .sheet(item: $selectedCard) { card in
            PackCardPreviewView(card: card) {
                addCard(card)
            }
        }
    }

    private func generateSuggestions() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load all available cards from packs
            let availableCards = try await loader.getAllUnaddedCards(progressMap: progressMap)

            // Generate suggestions
            let result = await engine.generateSuggestions(
                userCards: allCards,
                availableCards: availableCards,
                maxSuggestions: 10
            )

            suggestions = result
            AppLogger.suggestions.info("Generated \(result.cards.count) suggestions (AI: \(result.usedAI))")
        } catch {
            errorMessage = "Failed to load content packs: \(error.localizedDescription)"
            AppLogger.suggestions.error("Suggestion generation failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    private func addCard(_ packCard: PackCard) {
        // Create user card
        let card = packCard.toCard()
        modelContext.insert(card)

        // Update progress
        let progress = getOrCreateProgress(for: packCard.packId)
        progress.markAsAdded(cardId: packCard.id)

        do {
            try modelContext.save()
            // Refresh suggestions after adding
            Task {
                await generateSuggestions()
            }
            AppLogger.suggestions.info("Added suggested card \(packCard.id)")
        } catch {
            AppLogger.suggestions.error("Failed to save card: \(error.localizedDescription)")
        }
    }

    private func getOrCreateProgress(for packId: String) -> UserPackProgress {
        if let existing = progressMap[packId] {
            return existing
        }

        let newProgress = UserPackProgress(packId: packId)
        modelContext.insert(newProgress)
        return newProgress
    }
}

// MARK: - Suggestion Card Row

struct SuggestionCardRow: View {
    let card: PackCard

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.front)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text(card.back)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let hint = card.hint {
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb.min")
                            .font(.caption2)
                            .accessibilityHidden(true)
                        Text(hint)
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                }
            }

            Spacer()

            if !card.tags.isEmpty {
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(card.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                }
            }

            Image(systemName: "plus.circle.fill")
                .foregroundStyle(Color.accentColor)
                .font(.title3)
                .accessibilityLabel("Add card")
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    SuggestionsView(allCards: [], packProgress: [])
        .modelContainer(for: [Card.self, UserPackProgress.self], inMemory: true)
}
