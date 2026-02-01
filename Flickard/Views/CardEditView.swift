import SwiftUI
import SwiftData

struct CardEditView: View {
    let card: Card
    
    @State private var front: String
    @State private var back: String
    
    @State private var isEditing = false
    @State private var creating: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(card: Card, creating: Bool = false) {
        self.card = card
        self.back = card.back
        self.front = card.front
        self.creating = creating
    }
    
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 20) {
                Text("Front")
                    .font(.headline)
                    .foregroundStyle(.cyan)
                HStack {
                    TextField("Front", text: $front)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                    if !front.isEmpty {
                        Button {
                            front = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear front")
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Back")
                    .font(.headline)
                    .foregroundStyle(.cyan)
                HStack {
                    TextField("Back", text: $back)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                    if !back.isEmpty {
                        Button {
                            back = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear back")
                    }
                }
            }
        }
        .navigationTitle("Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveCard()
                    dismiss()
                }
            }
        }
    }
    private func saveCard() {
        if front.isEmpty && back.isEmpty {
            modelContext.delete(card)
            return
        }
        // Editing existing card
        card.front = front
        card.back = back
    }
}

@available(iOS 18.0, *)
#Preview(Card.sampleData.first?.front ?? "Edit Card", traits: .cardSampleData) {
    if let first = Card.sampleData.first {
        NavigationStack {
            CardEditView(card: first)
        }
    } else {
        NavigationStack {
            CardEditView(card: Card(front: "Front", back: "Back"))
        }
    }
}
