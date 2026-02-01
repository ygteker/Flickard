import SwiftUI
import SwiftData

struct CardSampleData: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(for: Card.self, configurations: .init(isStoredInMemoryOnly: true))
        Card.sampleData.forEach { container.mainContext.insert($0) }
        try? container.mainContext.save()  // Save the inserted data!
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

@available(iOS 18.0, *)
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var cardSampleData: Self = .modifier(CardSampleData())
}

