//
//  ContentView.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 20.01.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @Query(sort: \Card.front) private var storedCards: [Card]

    var body: some View {
        TabView(selection: $selectedTab) {
            // Main tab: Cards list
            CardsListView()
                .tabItem {
                    Image(systemName: "rectangle.stack")
                    Text("Cards")
                }
                .tag(0)

            // Optional: Your existing swipeable cards demo
            VStack {
                let cards: [CardView.Model] = storedCards.map { card in
                    CardView.Model(id: card.id, front: card.front, back: card.back)
                }
                let model = SwipeableCardsView.Model(cards: cards)
                SwipeableCardsView(model: model) { model in
                    model.reset()
                }
            }
            .padding()
            .tabItem {
                Image(systemName: "hand.draw")
                Text("Swipe")
            }
            .tag(1)

            // Placeholder settings tab
            NavigationStack {
                List {
                    Section("General") {
                        Toggle("Example toggle", isOn: .constant(true))
                    }
                }
                .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(2)
        }
    }
}
#Preview("ContentView") {
    ContentView()
}

