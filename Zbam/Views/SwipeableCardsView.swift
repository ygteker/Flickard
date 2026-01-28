import SwiftUI
import Combine
import SwiftData

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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragState = CGSize.zero
    @State private var cardRotation: Double = 0
    @State private var store: CardStore? = nil
    @State private var pendingSwipes: [(UUID, CardView.SwipeDirection)] = []

    private let swipeThreshold: CGFloat = 100.0
    private let rotationFactor: Double = 35.0

    var action: (Model) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if model.unswipedCards.isEmpty && model.swipedCards.isEmpty {
                    emptyCardsView
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else if model.unswipedCards.isEmpty {
                    swipingCompletionView
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    // Card counter
                    VStack {
                        Spacer()
                        HStack {
                            Text("\(model.swipedCards.count + 1)")
                                .fontWeight(.bold)
                            Text("of \(model.swipedCards.count + model.unswipedCards.count)")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 40)
                    }

                    // Card stack
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
                                        withAnimation(reduceMotion ? .none : .easeOut(duration: 0.5)) {
                                            self.dragState.width = self.dragState.width > 0 ? 1000 : -1000
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.model.removeTopCard()
                                            self.dragState = .zero
                                        }
                                        pendingSwipes.append((card.id, swipeDirection))
                                    } else {
                                        withAnimation(reduceMotion ? .none : .spring()) {
                                            self.dragState = .zero
                                            self.cardRotation = 0
                                        }
                                    }
                                }
                        )
                    }

                    // Swipe hints
                    HStack {
                        SwipeHintView(direction: .left, isActive: dragState.width < -30)
                        Spacer()
                        SwipeHintView(direction: .right, isActive: dragState.width > 30)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
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
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text("No Cards Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add some cards to start practicing")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    var swipingCompletionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(.green)
                .accessibilityLabel("Completed")

            VStack(spacing: 8) {
                Text("Well Done!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("You've reviewed all \(model.swipedCards.count) cards")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                action(model)
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .accessibilityHidden(true)
                    Text("Practice Again")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel("Practice Again")
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
    }
}

private struct SwipeHintView: View {
    enum Direction {
        case left, right
    }

    let direction: Direction
    let isActive: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: direction == .left ? "xmark" : "checkmark")
                .font(.title2)
                .fontWeight(.bold)
                .accessibilityHidden(true)

            Text(direction == .left ? "Still Learning" : "Got It")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(direction == .left ? Color.red : Color.green)
        .opacity(isActive ? 1.0 : 0.5)
        .transaction { transaction in
            transaction.animation = transaction.animation
        }
        .accessibilityLabel(direction == .left ? "Still Learning" : "Got It")
    }
}

#Preview {
    SwipeableCardsView(model: SwipeableCardsView.Model(cards: [
        CardView.Model(id: UUID(), front: "What is SwiftUI?", back: "A declarative framework for building UIs"),
        CardView.Model(id: UUID(), front: "What is Swift?", back: "A powerful programming language by Apple"),
        CardView.Model(id: UUID(), front: "What is Xcode?", back: "Apple's IDE for development")
    ])) { model in
        model.reset()
    }
    .modelContainer(for: [Card.self], inMemory: true)
}

#Preview("Empty State") {
    SwipeableCardsView(model: SwipeableCardsView.Model(cards: [])) { _ in }
        .modelContainer(for: [Card.self], inMemory: true)
}
