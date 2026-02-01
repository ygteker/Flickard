import Foundation

/// Difficulty levels aligned with CEFR standards
enum DifficultyLevel: String, Codable, CaseIterable, Comparable {
    case beginner    // A1
    case elementary  // A2
    case intermediate // B1
    case upperIntermediate // B2
    case advanced    // C1
    case mastery     // C2

    var displayName: String {
        switch self {
        case .beginner: return "Beginner (A1)"
        case .elementary: return "Elementary (A2)"
        case .intermediate: return "Intermediate (B1)"
        case .upperIntermediate: return "Upper Intermediate (B2)"
        case .advanced: return "Advanced (C1)"
        case .mastery: return "Mastery (C2)"
        }
    }

    var shortName: String {
        switch self {
        case .beginner: return "A1"
        case .elementary: return "A2"
        case .intermediate: return "B1"
        case .upperIntermediate: return "B2"
        case .advanced: return "C1"
        case .mastery: return "C2"
        }
    }

    private var sortOrder: Int {
        switch self {
        case .beginner: return 0
        case .elementary: return 1
        case .intermediate: return 2
        case .upperIntermediate: return 3
        case .advanced: return 4
        case .mastery: return 5
        }
    }

    static func < (lhs: DifficultyLevel, rhs: DifficultyLevel) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

/// Metadata for a content pack
struct ContentPack: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let difficultyLevel: DifficultyLevel
    let cardCount: Int
    let iconName: String
    let tags: [String]

    static func == (lhs: ContentPack, rhs: ContentPack) -> Bool {
        lhs.id == rhs.id
    }
}

/// Container for a pack file that includes both metadata and cards
struct PackFile: Codable {
    let pack: ContentPack
    let cards: [PackCard]
}

/// Manifest file containing list of all available packs
struct PackManifest: Codable {
    let packs: [ContentPack]
}
