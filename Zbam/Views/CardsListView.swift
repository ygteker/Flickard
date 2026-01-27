import SwiftUI
import SwiftData

struct CardsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Card.front) private var cards: [Card]
    @State private var isAddingCard: Bool = false
    @State private var editingCard: Card? = nil
    @State private var expandedCardId: UUID? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(cards, id: \.id) { card in
                    CardRowView(
                        card: card,
                        isExpanded: expandedCardId == card.id,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if expandedCardId == card.id {
                                    expandedCardId = nil
                                } else {
                                    expandedCardId = card.id
                                }
                            }
                        },
                        onEdit: {
                            editingCard = card
                        }
                    )
                }
                .onDelete(perform: deleteCard)
                //todo remove
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
// MARK: - Card Row View with Expandable Stats

struct CardRowView: View {
    let card: Card
    let isExpanded: Bool
    let onTap: () -> Void
    let onEdit: () -> Void
    
    private var swipeStats: (right: Int, left: Int) {
        var rightCount = 0
        var leftCount = 0
        
        for swipe in card.lastSwipes {
            if swipe == "r" {
                rightCount += 1
            } else if swipe == "l" {
                leftCount += 1
            }
        }
        
        return (rightCount, leftCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main card info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.front)
                        .font(.headline)
                    Text(card.back)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.secondary)
                    .imageScale(.small)
            }
            .animation(nil, value: isExpanded)  // Prevent animation on main text
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            
            // Expandable stats section
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    let stats = swipeStats
                    let total = stats.right + stats.left
                    
                    if total == 0 {
                        Text("No swipes yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Swipe History")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            // Right swipes bar
                            HStack(spacing: 8) {
                                Image(systemName: "hand.thumbsup.fill")
                                    .foregroundStyle(.green)
                                    .frame(width: 20)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Background bar
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 20)
                                        
                                        // Filled bar
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.green)
                                            .frame(
                                                width: geometry.size.width * CGFloat(stats.right) / CGFloat(total),
                                                height: 20
                                            )
                                    }
                                }
                                .frame(height: 20)
                                
                                Text("\(stats.right)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 30, alignment: .trailing)
                            }
                            
                            // Left swipes bar
                            HStack(spacing: 8) {
                                Image(systemName: "hand.thumbsdown.fill")
                                    .foregroundStyle(.red)
                                    .frame(width: 20)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Background bar
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 20)
                                        
                                        // Filled bar
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.red)
                                            .frame(
                                                width: geometry.size.width * CGFloat(stats.left) / CGFloat(total),
                                                height: 20
                                            )
                                    }
                                }
                                .frame(height: 20)
                                
                                Text("\(stats.left)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 30, alignment: .trailing)
                            }
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .leading) {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "note.text")
            }
            .tint(.blue)
        }
    }
}

