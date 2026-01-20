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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(cards, id: \.id) { card in
                    Text(card.front)
                }
                .onDelete(perform: deleteCard)
                let newCards = cards.map { CardView.Model(front: $0.front, back: $0.back)}
                let model = SwipeableCardsView.Model(cards: newCards)
                NavigationLink("Start Swiping") {
                    SwipeableCardsView(model: model) { model in
                        print(model.swipedCards)
                        model.reset()
                    }
                }
                .padding(12)
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
        }
    }
    private func deleteCard(at offsets: IndexSet) {
        for index in offsets {
            let card = cards[index]
            modelContext.delete(card)
        }
    }
}

#Preview(traits: .cardSampleData) {
    CardsListView()
}
