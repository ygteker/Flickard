//
//  CardsView.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 17.01.26.
//

import SwiftUI
import SwiftData

struct CardsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Card.front) private var cards: [Card]
    @State private var isAddingCard: Bool = false
    @State private var editingCard: Card? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(cards, id: \.id) { card in
                    Text(card.front)
                        .swipeActions(edge: .leading) {
                            Button {
                                editingCard = card
                            } label: {
                                Label("Edit", systemImage: "note.text")
                            }
                            .tint(.blue)
                        }
                }
                .onDelete(perform: deleteCard)
                let newCards = cards.map { CardView.Model(id: $0.id, front: $0.front, back: $0.back)}
            }
            
            .navigationTitle("Cards")
            .toolbar {
                Button(action: {
                    isAddingCard = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Scrum")
            }
            .sheet(isPresented: $isAddingCard) {
                NavigationStack {
                    // Use the creation view that has a no-arg initializer
                    CreateCardView()
                        .navigationTitle("Create New Card")
                }
            }
            .sheet(item: $editingCard) { card in
                NavigationStack {
                    CardEditView(card: card)
                        .navigationTitle("Edit Card")
                }
            }
        }
    }
    private func deleteCard(at offsets: IndexSet) {
        for index in offsets {
            let card = cards[index]
            modelContext.delete(card)
        }
        try? modelContext.save()
    }
}

#Preview(traits: .cardSampleData) {
    CardsListView()
}
