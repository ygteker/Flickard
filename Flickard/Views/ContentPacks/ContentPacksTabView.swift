import SwiftUI
import SwiftData

/// Main tab view for content packs with Browse/For You segmented control
struct ContentPacksTabView: View {
    enum TabSelection: String, CaseIterable {
        case forYou = "For You"
        case browse = "Browse"
    }

    @State private var selectedTab: TabSelection = .forYou
    @Environment(\.modelContext) private var modelContext
    @Query private var allCards: [Card]
    @Query private var packProgress: [UserPackProgress]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedTab) {
                    ForEach(TabSelection.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                switch selectedTab {
                case .forYou:
                    SuggestionsView(
                        allCards: allCards,
                        packProgress: packProgress
                    )
                case .browse:
                    ContentPacksView(packProgress: packProgress)
                }
            }
            .navigationTitle("Packs")
        }
    }
}

#Preview {
    ContentPacksTabView()
        .modelContainer(for: [Card.self, UserPackProgress.self], inMemory: true)
}
