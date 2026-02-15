import SwiftUI
import SwiftData
import OSLog

struct CreateStackView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Card.front) private var allCards: [Card]

    @State private var name: String = ""
    @State private var isAIManaged: Bool = true
    @State private var selectedCardIDs: Set<UUID> = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Stack Name") {
                    TextField("e.g. Verbs, Travel, Daily Practice", text: $name)
                }

                Section {
                    Toggle("AI-Managed", isOn: $isAIManaged)
                } footer: {
                    Text("When enabled, AI will automatically add cards you struggle with and remove mastered ones.")
                }

                Section("Seed Cards (\(selectedCardIDs.count) selected)") {
                    if allCards.isEmpty {
                        Text("No cards available")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(allCards) { card in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(card.front)
                                        .font(.body)
                                    Text(card.back)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if selectedCardIDs.contains(card.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedCardIDs.contains(card.id) {
                                    selectedCardIDs.remove(card.id)
                                } else {
                                    selectedCardIDs.insert(card.id)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Stack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createStack()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func createStack() {
        let stack = Stack(name: name.trimmingCharacters(in: .whitespaces), isAIManaged: isAIManaged)
        stack.addCards(Array(selectedCardIDs))
        modelContext.insert(stack)
        try? modelContext.save()
        AppLogger.stacks.info("Created stack '\(stack.name)' with \(selectedCardIDs.count) cards")
        dismiss()
    }
}

#Preview {
    CreateStackView()
        .modelContainer(for: [Card.self, Stack.self], inMemory: true)
}
