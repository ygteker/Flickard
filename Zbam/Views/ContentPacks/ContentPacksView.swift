import SwiftUI
import SwiftData
import OSLog

/// Browse all available content packs with category filters
struct ContentPacksView: View {
    let packProgress: [UserPackProgress]

    @StateObject private var loader = ContentPackLoader.shared
    @State private var packs: [ContentPack] = []
    @State private var selectedCategory: PackCategory?
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var filteredPacks: [ContentPack] {
        guard let category = selectedCategory else {
            return packs
        }
        return packs.filter { $0.category == category }
    }

    private func progressFor(packId: String) -> UserPackProgress? {
        packProgress.first { $0.packId == packId }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All",
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }

                    ForEach(PackCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.displayName,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }

            Divider()

            if isLoading {
                Spacer()
                ProgressView("Loading packs...")
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(error)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await loadPacks()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                Spacer()
            } else if filteredPacks.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No packs available")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPacks) { pack in
                            NavigationLink(destination: PackDetailView(
                                pack: pack,
                                progress: progressFor(packId: pack.id)
                            )) {
                                PackRowView(
                                    pack: pack,
                                    addedCount: progressFor(packId: pack.id)?.addedCount ?? 0
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await loadPacks()
        }
    }

    private func loadPacks() async {
        isLoading = true
        errorMessage = nil

        do {
            let manifest = try await loader.loadManifest()
            packs = manifest.packs.sorted { $0.difficultyLevel < $1.difficultyLevel }
            AppLogger.packs.info("Loaded \(packs.count) packs for browsing")
        } catch {
            errorMessage = error.localizedDescription
            AppLogger.packs.error("Failed to load packs: \(error.localizedDescription)")
        }

        isLoading = false
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Pack Row

struct PackRowView: View {
    let pack: ContentPack
    let addedCount: Int

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: pack.iconName)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(pack.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(pack.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label(pack.difficultyLevel.shortName, systemImage: "chart.bar.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Label("\(pack.cardCount) cards", systemImage: "rectangle.stack")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if addedCount > 0 {
                        Label("\(addedCount) added", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        ContentPacksView(packProgress: [])
    }
    .modelContainer(for: [Card.self, UserPackProgress.self], inMemory: true)
}
