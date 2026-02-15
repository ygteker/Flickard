import SwiftUI
import SwiftData
import OSLog

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @Query(sort: \Card.front) private var storedCards: [Card]
    @Query(sort: \Stack.createdAt) private var stacks: [Stack]
    @State private var swipeableModel: SwipeableCardsView.Model?
    @State private var selectedStackID: UUID?
    @State private var hasBegunSession = false

    private var selectedStack: Stack? {
        guard let id = selectedStackID else { return nil }
        return stacks.first { $0.id == id }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Main tab: Cards list
            CardsListView()
                .tabItem {
                    Image(systemName: "rectangle.stack")
                    Text("Cards")
                }
                .tag(0)

            // Swipe tab with stack picker
            VStack(spacing: 0) {
                if !stacks.isEmpty {
                    StackPickerView(stacks: stacks, selectedStackID: $selectedStackID)
                }

                Group {
                    if let model = swipeableModel {
                        SwipeableCardsView(model: model, stack: selectedStack) { model in
                            // Reset: begin new session for stack
                            if let stack = selectedStack {
                                stack.beginSession()
                            }
                            hasBegunSession = false
                            initializeSwipeableModel()
                            model.reset()
                        }
                    } else {
                        Color.clear
                            .onAppear {
                                initializeSwipeableModel()
                            }
                    }
                }
            }
            .tabItem {
                Image(systemName: "hand.draw")
                Text("Swipe")
            }
            .tag(1)

            // Stats tab
            StatsView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Stats")
                }
                .tag(2)

            // Packs tab
            ContentPacksTabView()
                .tabItem {
                    Image(systemName: "square.stack.3d.up.fill")
                    Text("Packs")
                }
                .tag(3)

            // Settings tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            AppLogger.ui.info("Tab changed from \(oldValue) to \(newValue)")
            if newValue == 1 {
                // Begin session when switching to swipe tab
                if !hasBegunSession, let stack = selectedStack {
                    stack.beginSession()
                    hasBegunSession = true
                }
                initializeSwipeableModel()
            }
        }
        .onChange(of: storedCards) { oldValue, newValue in
            AppLogger.data.info("Cards updated. Count: \(newValue.count)")
            initializeSwipeableModel()
        }
        .onChange(of: selectedStackID) { _, _ in
            hasBegunSession = false
            if let stack = selectedStack {
                stack.beginSession()
                hasBegunSession = true
            }
            initializeSwipeableModel()
        }
        .onAppear {
            // Auto-select first stack if none selected
            if selectedStackID == nil, let first = stacks.first {
                selectedStackID = first.id
            }
        }
    }

    private func initializeSwipeableModel() {
        if let stack = selectedStack {
            // Filter to stack's cards, preserving order (including duplicates)
            let cardMap = Dictionary(uniqueKeysWithValues: storedCards.map { ($0.id, $0) })
            let cards: [CardView.Model] = stack.cardIDs.compactMap { id in
                guard let card = cardMap[id] else { return nil }
                return CardView.Model(
                    id: card.id,
                    front: card.front,
                    back: card.back,
                    isMastered: stack.isGrayedOut(card.id)
                )
            }
            AppLogger.cards.info("Initializing swipeable model with \(cards.count) cards from stack '\(stack.name)'")
            swipeableModel = SwipeableCardsView.Model(cards: cards)
        } else {
            // No stack selected — show all cards
            let cards: [CardView.Model] = storedCards.map { card in
                CardView.Model(id: card.id, front: card.front, back: card.back)
            }
            AppLogger.cards.info("Initializing swipeable model with \(cards.count) cards (all)")
            swipeableModel = SwipeableCardsView.Model(cards: cards)
        }
    }
}
#Preview("ContentView") {
    ContentView()
}

