import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var cards: [Card]
    @State private var selectedSector: SwipeSector? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    enum SwipeSector: String {
        case right, left
        
        var color: Color {
            self == .right ? .green : .red
        }
        
        var character: String {
            self == .right ? "r" : "l"
        }
    }
    
    private var swipeStats: (right: Int, left: Int) {
        cards.reduce(into: (right: 0, left: 0)) { result, card in
            for swipe in card.lastSwipes {
                if swipe == "r" { result.right += 1 }
                else if swipe == "l" { result.left += 1 }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    let stats = swipeStats
                    
                    if stats.right == 0 && stats.left == 0 {
                        ContentUnavailableView(
                            "No Swipe Data",
                            systemImage: "chart.pie",
                            description: Text("Start swiping cards to see statistics")
                        )
                    } else {
                        chartView(stats: stats)
                        
                        if let sector = selectedSector {
                            detailsList(for: sector)
                        } else {
                            hintView
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Statistics")
        }
    }
    
    // MARK: - Chart View
    
    private func chartView(stats: (right: Int, left: Int)) -> some View {
        ZStack {
            Chart {
                sectorMark(count: stats.right, sector: .right)
                sectorMark(count: stats.left, sector: .left)
            }
            .frame(height: 300)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
            .scaleEffect(selectedSector != nil ? 1.05 : 1.0)
            
            tapAreas()
        }
        .padding()
    }
    
    private func sectorMark(count: Int, sector: SwipeSector) -> some ChartContent {
        SectorMark(
            angle: .value("Count", count),
            innerRadius: .ratio(0.5),
            angularInset: 4
        )
        .foregroundStyle(sector.color)
        .cornerRadius(6)
        .opacity(selectedSector != nil && selectedSector != sector ? 0.5 : 1.0)
        .annotation(position: .overlay) {
            Text("\(count)")
                .font(.headline)
                .foregroundStyle(.white)
                .accessibilityLabel("\(sector.rawValue) swipes: \(count)")
        }
    }
    
    private func tapAreas() -> some View {
        HStack(spacing: 0) {
            tapArea(for: .left)
            tapArea(for: .right)
        }
        .frame(height: 300)
        .padding()
    }
    
    private func tapArea(for sector: SwipeSector) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .accessibilityLabel("Select \(sector.rawValue) swipes")
            .accessibilityHint(selectedSector == sector ? "Tap to deselect" : "Tap to view details")
            .onTapGesture {
                withAnimation(reduceMotion ? .none : .default) {
                    selectedSector = selectedSector == sector ? nil : sector
                }
            }
    }
    
    // MARK: - Details List
    
    private var hintView: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.tap")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("Tap on the chart to see detailed statistics")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        }
        .padding(.horizontal)
        .transition(.opacity.combined(with: .scale))
    }
    
    private func detailsList(for sector: SwipeSector) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(sector.rawValue.capitalized) Swipes Details")
                .font(.headline)
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)
            
            ForEach(cardsWithSwipes(for: sector), id: \.card.id) { item in
                cardRow(card: item.card, count: item.count, sector: sector)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func cardRow(card: Card, count: Int, sector: SwipeSector) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(card.front)
                    .font(.headline)
                Text(card.back)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(count)")
                .font(.title3)
                .bold()
                .foregroundStyle(sector.color)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Data Helpers
    
    private func cardsWithSwipes(for sector: SwipeSector) -> [(card: Card, count: Int)] {
        cards
            .compactMap { card in
                let count = card.lastSwipes.filter { $0 == sector.character }.count
                return count > 0 ? (card, count) : nil
            }
            .sorted { $0.count > $1.count }
    }
}
#Preview {
    @Previewable @State var container: ModelContainer = {
        let container = try! ModelContainer(
            for: Card.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        // Create cards with swipes
        let card1 = Card(front: "Table", back: "der Tisch")
        card1.swipeRight()
        card1.swipeRight()
        card1.swipeLeft()
        card1.swipeRight()
        
        let card2 = Card(front: "Apple", back: "der Apfel")
        card2.swipeRight()
        card2.swipeRight()
        card2.swipeRight()
        
        let card3 = Card(front: "Car", back: "das Auto")
        card3.swipeLeft()
        card3.swipeLeft()
        card3.swipeRight()
        
        let card4 = Card(front: "City", back: "die Stadt")
        card4.swipeLeft()
        card4.swipeLeft()
        card4.swipeLeft()
        card4.swipeLeft()
        
        container.mainContext.insert(card1)
        container.mainContext.insert(card2)
        container.mainContext.insert(card3)
        container.mainContext.insert(card4)
        
        return container
    }()
    
    StatsView()
        .modelContainer(container)
}

