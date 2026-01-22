import SwiftUI
import Combine

struct SwipeableCardsView: View {
    class Model: ObservableObject {
        private var originalCards: [CardView.Model]
        @Published var unswipedCards: [CardView.Model]
        @Published var swipedCards: [CardView.Model]
        
        init(cards: [CardView.Model]) {
            self.originalCards = cards
            self.unswipedCards = cards
            self.swipedCards = []
        }
        
        func removeTopCard() {
            if !unswipedCards.isEmpty {
                guard let card = unswipedCards.first else { return }
                unswipedCards.removeFirst()
                swipedCards.append(card)
            }
        }
        
        func updateTopCardSwipeDirection(_ direction: CardView.SwipeDirection) {
            if !unswipedCards.isEmpty {
                unswipedCards[0].swipeDirection = direction
            }
        }
        
        func reset() {
            unswipedCards = originalCards
            swipedCards = []
        }
    }
    
    @ObservedObject var model: Model
    @Environment(\.modelContext) private var context
    @State private var dragState = CGSize.zero
    @State private var cardRotation: Double = 0
    @State private var store: CardStore? = nil
    @State private var pendingSwipes: [(UUID, CardView.SwipeDirection)] = []

    private let swipeThreshold: CGFloat = 100.0
    private let rotationFactor: Double = 35.0 // This remains constant and should be fine
    
    var action: (Model) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if model.unswipedCards.isEmpty && model.swipedCards.isEmpty {
                
                emptyCardsView
                    .frame(width: geometry.size.width, height: geometry.size.height)
            } else if model.unswipedCards.isEmpty {
                swipingCompletionView
                    .frame(width: geometry.size.width, height: geometry.size.height)
            } else {
                ZStack {
                    Color.white.ignoresSafeArea()
                    ForEach(model.unswipedCards.reversed(), id: \.id) { card in
                        let isTop = card == model.unswipedCards.first
                        let isSecond = card == model.unswipedCards.dropFirst().first
                        
                        CardView(
                            model: card,
                            size: geometry.size,
                            dragOffset: dragState,
                            isTopCard: isTop,
                            isSecondCard: isSecond
                        )
                        .offset(x: isTop ? dragState.width : 0)
                        .rotationEffect(.degrees(isTop ? Double(dragState.width) / rotationFactor : 0))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    self.dragState = gesture.translation
                                    self.cardRotation = Double(gesture.translation.width) / rotationFactor
                                }
                                .onEnded { _ in
                                    if abs(self.dragState.width) > swipeThreshold {
                                        let swipeDirection: CardView.SwipeDirection = self.dragState.width > 0 ? .right : .left
                                        model.updateTopCardSwipeDirection(swipeDirection)
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            self.dragState.width = self.dragState.width > 0 ? 1000 : -1000
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.model.removeTopCard()
                                            self.dragState = .zero
                                        }
                                        pendingSwipes.append((card.id, swipeDirection))
                                    } else {
                                        withAnimation(.spring()) {
                                            self.dragState = .zero
                                            self.cardRotation = 0
                                        }
                                    }
                                }
                        )
                        .animation(.easeInOut, value: dragState)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if store == nil { store = CardStore(context: context) }
        }
        .onDisappear() {
            for (id, direction) in pendingSwipes {
                store?.swipe(cardId: id, direction: direction)
            }
            pendingSwipes.removeAll()
        }
    }
    
    var emptyCardsView: some View {
        VStack {
            Text("No Cards")
                .font(.title)
                .padding(.bottom, 20)
                .foregroundStyle(.gray)
        }
    }
    
    var swipingCompletionView: some View {
        VStack {
            Text("Finished Swiping")
                .font(.title)
                .padding(.bottom, 20)
            Button(action: {
                action(model)
            }) {
                Text("Reset")
                    .font(.headline)
                    .frame(width: 200, height: 50)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
//            Button(action: {
//                NavigationLink(destination: CardsListView) {
//                    EmptyView()
//                }
//                .hidden
//            }) {
//                Text("Return to List")
//                    .font(.headline)
//                    .frame(width: 200, height: 50)
//                    .background(Color.accentColor)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
        }
    }
}
