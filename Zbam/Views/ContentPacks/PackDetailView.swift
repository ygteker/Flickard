import SwiftUI
import SwiftData
import OSLog

/// View all cards in a pack, add individually or bulk
struct PackDetailView: View {
    let pack: ContentPack
    let progress: UserPackProgress?

    @Environment(\.modelContext) private var modelContext
    @StateObject private var loader = ContentPackLoader.shared
    @State private var cards: [PackCard] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedCard: PackCard?
    @State private var showingBulkAddConfirm = false
    @State private var localProgress: UserPackProgress?

    private var unaddedCards: [PackCard] {
        guard let progress = localProgress ?? progress else {
            return cards
        }
        return cards.filter { !progress.hasAdded(cardId: $0.id) }
    }

    private var addedCards: [PackCard] {
        guard let progress = localProgress ?? progress else {
            return []
        }
        return cards.filter { progress.hasAdded(cardId: $0.id) }
    }

    private func isCardAdded(_ cardId: String) -> Bool {
        (localProgress ?? progress)?.hasAdded(cardId: cardId) ?? false
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView("Loading cards...")
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
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Pack header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: pack.iconName)
                                    .font(.title)
                                    .foregroundStyle(Color.accentColor)
                                    .accessibilityHidden(true)
                                Text(pack.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }

                            Text(pack.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 16) {
                                Label(pack.difficultyLevel.displayName, systemImage: "chart.bar.fill")
                                Label(pack.category.displayName, systemImage: pack.category.iconName)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            // Progress bar
                            if !cards.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("\(addedCards.count) of \(cards.count) cards added")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        if !unaddedCards.isEmpty {
                                            Button("Add All") {
                                                showingBulkAddConfirm = true
                                            }
                                            .font(.caption)
                                            .buttonStyle(.borderedProminent)
                                        }
                                    }

                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color(.systemGray5))
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.accentColor)
                                                .frame(width: geo.size.width * CGFloat(addedCards.count) / CGFloat(cards.count))
                                        }
                                    }
                                    .frame(height: 8)
                                    .accessibilityValue("\(addedCards.count) of \(cards.count) cards added")
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Cards list
                        if !unaddedCards.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Available Cards")
                                    .font(.headline)
                                    .padding(.horizontal, 4)
                                    .accessibilityAddTraits(.isHeader)

                                ForEach(unaddedCards) { card in
                                    Button {
                                        selectedCard = card
                                    } label: {
                                        PackCardRowView(card: card, isAdded: false)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if !addedCards.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Added Cards")
                                    .font(.headline)
                                    .padding(.horizontal, 4)
                                    .foregroundStyle(.secondary)
                                    .accessibilityAddTraits(.isHeader)

                                ForEach(addedCards) { card in
                                    PackCardRowView(card: card, isAdded: true)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(pack.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadCards()
        }
        .sheet(item: $selectedCard) { card in
            PackCardPreviewView(card: card) {
                addCard(card)
            }
        }
        .confirmationDialog(
            "Add All Cards",
            isPresented: $showingBulkAddConfirm,
            titleVisibility: .visible
        ) {
            Button("Add \(unaddedCards.count) Cards") {
                addAllCards()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Add all \(unaddedCards.count) remaining cards from this pack to your collection?")
        }
    }

    private func loadCards() async {
        isLoading = true
        errorMessage = nil

        do {
            let packFile = try await loader.loadPack(id: pack.id)
            cards = packFile.cards
            localProgress = progress
            AppLogger.packs.info("Loaded \(cards.count) cards from pack \(pack.id)")
        } catch {
            errorMessage = error.localizedDescription
            AppLogger.packs.error("Failed to load pack \(pack.id): \(error.localizedDescription)")
        }

        isLoading = false
    }

    private func addCard(_ packCard: PackCard) {
        // Create user card
        let card = packCard.toCard()
        modelContext.insert(card)

        // Update progress
        let progress = getOrCreateProgress()
        progress.markAsAdded(cardId: packCard.id)

        do {
            try modelContext.save()
            localProgress = progress
            AppLogger.packs.info("Added card \(packCard.id) from pack \(pack.id)")
        } catch {
            AppLogger.packs.error("Failed to save card: \(error.localizedDescription)")
        }
    }

    private func addAllCards() {
        let progress = getOrCreateProgress()

        for packCard in unaddedCards {
            let card = packCard.toCard()
            modelContext.insert(card)
            progress.markAsAdded(cardId: packCard.id)
        }

        do {
            try modelContext.save()
            localProgress = progress
            AppLogger.packs.info("Bulk added \(unaddedCards.count) cards from pack \(pack.id)")
        } catch {
            AppLogger.packs.error("Failed to bulk save cards: \(error.localizedDescription)")
        }
    }

    private func getOrCreateProgress() -> UserPackProgress {
        if let existing = localProgress ?? progress {
            return existing
        }

        let newProgress = UserPackProgress(packId: pack.id)
        modelContext.insert(newProgress)
        return newProgress
    }
}

// MARK: - Pack Card Row

struct PackCardRowView: View {
    let card: PackCard
    let isAdded: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.front)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isAdded ? .secondary : .primary)

                Text(card.back)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !card.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(card.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer()

            if isAdded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .accessibilityLabel("Card already added")
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .opacity(isAdded ? 0.6 : 1.0)
    }
}

#Preview {
    NavigationStack {
        PackDetailView(
            pack: ContentPack(
                id: "test",
                name: "Test Pack",
                description: "A test pack for preview",
                category: .basics,
                difficultyLevel: .beginner,
                cardCount: 10,
                iconName: "star.fill"
            ),
            progress: nil
        )
    }
    .modelContainer(for: [Card.self, UserPackProgress.self], inMemory: true)
}
