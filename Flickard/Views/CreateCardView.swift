import SwiftUI
import SwiftData

struct CreateCardView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

//    @State private var store: CardStore? = nil
    @State private var frontValue: String = ""
    @State private var backValue: String = ""

    var body: some View {
        Form{
            VStack(alignment: .leading, spacing: 20) {
                TextField("Front", text: $frontValue)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .accessibilityLabel("Card front text")
                TextField("Back", text: $backValue)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .accessibilityLabel("Card back text")
            }
        }
        .navigationTitle("Create New Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    submitValues()
                    dismiss()
                }
            }
        }
//        .onAppear {
//            if store == nil { store = CardStore(context: context) }
//        }
    }
    
    func submitValues() {
//        try? store?.addCard(cardId: UUID(), front: frontValue, back: backValue)
        let card = Card(front: frontValue, back: backValue)
        context.insert(card)
        try? context.save()
    }
}

#Preview {
    NavigationStack {
        CreateCardView()
            .modelContainer(for: [Card.self], inMemory: true)
    }
}
