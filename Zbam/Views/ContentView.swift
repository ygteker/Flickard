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
    @State private var swipeableModel: SwipeableCardsView.Model?

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
            Group {
                if let model = swipeableModel {
                    SwipeableCardsView(model: model) { model in
                        model.reset()
                    }
                } else {
                    Color.clear
                        .onAppear {
                            initializeSwipeableModel()
                        }
                }
            }
            .tabItem {
                Image(systemName: "hand.draw")
                Text("Swipe")
            }
            .tag(1)

            // Placeholder settings tab
            StatsView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Stats")
                }
                .tag(2)
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
            .tag(3)
        }
        .onChange(of: storedCards) { oldValue, newValue in
            // Update the model when cards change (added/edited/deleted)
            initializeSwipeableModel()
        }
    }
    
    private func initializeSwipeableModel() {
        let cards: [CardView.Model] = storedCards.map { card in
            CardView.Model(id: card.id, front: card.front, back: card.back)
        }
        
        // If model already exists, preserve its state but update cards if needed
        if swipeableModel == nil {
            swipeableModel = SwipeableCardsView.Model(cards: cards)
        } else {
            // Optionally update the original cards while preserving swiped state
            // For now, we'll keep the existing model to preserve state
        }
    }
}
#Preview("ContentView") {
    ContentView()
}

