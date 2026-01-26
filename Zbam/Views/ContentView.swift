//
//  ContentView.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 20.01.26.
//

import SwiftUI
import SwiftData
import OSLog

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
            SettingsView()
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(3)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            AppLogger.ui.info("Tab changed from \(oldValue) to \(newValue)")
        }
        .onChange(of: storedCards) { oldValue, newValue in
            AppLogger.data.info("Cards updated. Count: \(newValue.count)")
            // Update the model when cards change (added/edited/deleted)
            initializeSwipeableModel()
        }
    }
    
    private func initializeSwipeableModel() {
        AppLogger.cards.info("Initializing swipeable model with \(self.storedCards.count) cards")
        
        let cards: [CardView.Model] = storedCards.map { card in
            CardView.Model(id: card.id, front: card.front, back: card.back)
        }
        
        // Always create a new model to reflect current card state
        swipeableModel = SwipeableCardsView.Model(cards: cards)
        AppLogger.cards.info("Created/updated swipeable model with \(cards.count) cards")
    }
}
#Preview("ContentView") {
    ContentView()
}

