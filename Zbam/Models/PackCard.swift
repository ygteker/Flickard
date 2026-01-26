import Foundation

/// Individual card within a content pack
struct PackCard: Identifiable, Codable, Equatable {
    let id: String
    let packId: String
    let front: String
    let back: String
    let tags: [String]
    let hint: String?
    let example: String?

    /// Convert this pack card to a user's Card model for adding to their collection
    func toCard() -> Card {
        Card(front: front, back: back)
    }

    static func == (lhs: PackCard, rhs: PackCard) -> Bool {
        lhs.id == rhs.id && lhs.packId == rhs.packId
    }
}
