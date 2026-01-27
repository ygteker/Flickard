import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("darkMode") private var darkMode: Bool = false
    @State private var showDeleteAllCardsConfirmation = false
    @State private var showResetStatsConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    Toggle("Dark mode", isOn: $darkMode)
                    
                    Button("Delete all cards", role: .destructive) {
                        showDeleteAllCardsConfirmation = true
                    }
                    
                    Button("Reset stats", role: .destructive) {
                        showResetStatsConfirmation = true
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(buildNumber)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Legal") {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                }
                
                Section {
                    Link(destination: URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!) {
                        Label("Rate on App Store", systemImage: "star.fill")
                    }
                    
                    Button {
                        shareApp()
                    } label: {
                        Label("Share App", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Delete All Cards",
                isPresented: $showDeleteAllCardsConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All Cards", role: .destructive) {
                    deleteAllCards()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all your flashcards. This action cannot be undone.")
            }
            .confirmationDialog(
                "Reset Statistics",
                isPresented: $showResetStatsConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Stats", role: .destructive) {
                    resetStats()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will reset all your study statistics and progress. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    // MARK: - Helper Methods
    
    private func shareApp() {
        let appURL = "https://apps.apple.com/app/idYOUR_APP_ID"
        let activityVC = UIActivityViewController(
            activityItems: ["Check out Zbam - the best flashcard app!", appURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func deleteAllCards() {
        do {
            // Fetch all cards
            let descriptor = FetchDescriptor<Card>()
            let allCards = try modelContext.fetch(descriptor)
            
            // Delete each card
            for card in allCards {
                modelContext.delete(card)
            }
            
            // Save changes
            try modelContext.save()
            
            print("Successfully deleted \(allCards.count) cards")
        } catch {
            print("Failed to delete cards: \(error.localizedDescription)")
        }
    }
    
    private func resetStats() {
        do {
            // Fetch all cards
            let descriptor = FetchDescriptor<Card>()
            let allCards = try modelContext.fetch(descriptor)
            
            // Reset swipe history for each card
            for card in allCards {
                card.lastSwipes.removeAll()
            }
            
            // Save changes
            try modelContext.save()
            
            print("Successfully reset stats for \(allCards.count) cards")
        } catch {
            print("Failed to reset stats: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}
