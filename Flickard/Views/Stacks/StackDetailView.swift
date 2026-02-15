import SwiftUI
import SwiftData

struct StackDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var stack: Stack

    @Query(sort: \Card.front) private var allCards: [Card]
    @State private var showingAddCards = false

    private var activeCards: [Card] {
        let ids = Set(stack.cardIDs).subtracting(stack.pendingRemovalCardIDs)
        return allCards.filter { ids.contains($0.id) }
    }

    private var pendingCards: [Card] {
        let ids = Set(stack.pendingRemovalCardIDs)
        return allCards.filter { ids.contains($0.id) }
    }

    private var cardsNotInStack: [Card] {
        let stackCardSet = Set(stack.cardIDs)
        return allCards.filter { !stackCardSet.contains($0.id) }
    }

    var body: some View {
        List {
            // Header section
            Section {
                TextField("Stack Name", text: $stack.name)
                    .font(.headline)

                Toggle("AI-Managed", isOn: $stack.isAIManaged)
            } footer: {
                Text("\(stack.uniqueCardCount) unique cards (\(stack.cardIDs.count) total with duplicates)")
            }

            // Active cards
            Section("Active Cards (\(activeCards.count))") {
                if activeCards.isEmpty {
                    Text("No cards in this stack")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(activeCards) { card in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.front)
                                .font(.body)
                            Text(card.back)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            let card = activeCards[index]
                            stack.removeCard(card.id)
                        }
                        try? modelContext.save()
                    }
                }
            }

            // Pending removal
            if !pendingCards.isEmpty {
                Section {
                    ForEach(pendingCards) { card in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(card.front)
                                    .font(.body)
                                Text(card.back)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .opacity(0.5)

                            Spacer()

                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            let card = pendingCards[index]
                            stack.pendingRemovalCardIDs.removeAll { $0 == card.id }
                        }
                        try? modelContext.save()
                    }
                } header: {
                    Text("Pending Removal (\(pendingCards.count))")
                } footer: {
                    Text("These cards will be removed next session")
                }
            }

            // Add cards button
            Section {
                Button {
                    showingAddCards = true
                } label: {
                    Label("Add Cards", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle(stack.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddCards) {
            AddCardsToStackSheet(stack: stack, availableCards: cardsNotInStack)
        }
    }
}

// MARK: - Add Cards Sheet

struct AddCardsToStackSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let stack: Stack
    let availableCards: [Card]

    @State private var selectedIDs: Set<UUID> = []

    var body: some View {
        NavigationStack {
            Group {
                if availableCards.isEmpty {
                    ContentUnavailableView(
                        "No Cards Available",
                        systemImage: "rectangle.stack",
                        description: Text("All cards are already in this stack")
                    )
                } else {
                    cardSelectionList
                }
            }
            .navigationTitle("Add Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add (\(selectedIDs.count))") {
                        stack.addCards(Array(selectedIDs))
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(selectedIDs.isEmpty)
                }
            }
        }
    }

    private var cardSelectionList: some View {
        List {
            ForEach(availableCards) { card in
                cardRow(for: card)
            }
        }
    }

    private func cardRow(for card: Card) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(card.front)
                    .font(.body)
                Text(card.back)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if selectedIDs.contains(card.id) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if selectedIDs.contains(card.id) {
                selectedIDs.remove(card.id)
            } else {
                selectedIDs.insert(card.id)
            }
        }
    }
}
