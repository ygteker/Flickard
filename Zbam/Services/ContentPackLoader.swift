import Foundation
import OSLog
import Combine

/// Service for loading content packs from the app bundle
@MainActor
final class ContentPackLoader: ObservableObject {
    static let shared = ContentPackLoader()

    /// Cached manifest
    @Published private(set) var manifest: PackManifest?

    /// Cached pack files (packId -> PackFile)
    private var packCache: [String: PackFile] = [:]

    /// Error state
    @Published private(set) var loadError: Error?

    private init() {}

    // MARK: - Manifest Loading

    /// Load the pack manifest from bundle
    func loadManifest() async throws -> PackManifest {
        if let cached = manifest {
            return cached
        }

        AppLogger.packs.info("Loading pack manifest from bundle")

        guard let url = Bundle.main.url(forResource: "pack-manifest", withExtension: "json") else {
            let error = ContentPackError.manifestNotFound
            AppLogger.packs.error("Pack manifest not found in bundle")
            self.loadError = error
            throw error
        }

        do {
            let data = try Data(contentsOf: url)
            let manifest = try JSONDecoder().decode(PackManifest.self, from: data)
            self.manifest = manifest
            AppLogger.packs.info("Loaded manifest with \(manifest.packs.count) packs")
            return manifest
        } catch {
            AppLogger.packs.error("Failed to decode pack manifest: \(error.localizedDescription)")
            self.loadError = error
            throw ContentPackError.manifestDecodingFailed(error)
        }
    }

    // MARK: - Pack Loading

    /// Load a specific pack by ID
    func loadPack(id: String) async throws -> PackFile {
        if let cached = packCache[id] {
            return cached
        }

        AppLogger.packs.info("Loading pack: \(id)")

        guard let url = Bundle.main.url(forResource: id, withExtension: "json") else {
            let error = ContentPackError.packNotFound(id)
            AppLogger.packs.error("Pack not found: \(id)")
            throw error
        }

        do {
            let data = try Data(contentsOf: url)
            let packFile = try JSONDecoder().decode(PackFile.self, from: data)
            packCache[id] = packFile
            AppLogger.packs.info("Loaded pack '\(packFile.pack.name)' with \(packFile.cards.count) cards")
            return packFile
        } catch {
            AppLogger.packs.error("Failed to decode pack \(id): \(error.localizedDescription)")
            throw ContentPackError.packDecodingFailed(id, error)
        }
    }

    /// Load all packs referenced in the manifest
    func loadAllPacks() async throws -> [PackFile] {
        let manifest = try await loadManifest()
        var packs: [PackFile] = []

        for packMeta in manifest.packs {
            do {
                let packFile = try await loadPack(id: packMeta.id)
                packs.append(packFile)
            } catch {
                AppLogger.packs.warning("Skipping pack \(packMeta.id) due to load error: \(error.localizedDescription)")
            }
        }

        return packs
    }

    // MARK: - Card Filtering

    /// Get cards from a pack that the user hasn't added yet
    func getUnadaddedCards(from packFile: PackFile, progress: UserPackProgress?) -> [PackCard] {
        guard let progress = progress else {
            return packFile.cards
        }
        return packFile.cards.filter { !progress.hasAdded(cardId: $0.id) }
    }

    /// Get all unadded cards across all packs
    func getAllUnaddedCards(progressMap: [String: UserPackProgress]) async throws -> [PackCard] {
        let packs = try await loadAllPacks()
        var allUnadded: [PackCard] = []

        for packFile in packs {
            let progress = progressMap[packFile.pack.id]
            let unadded = getUnadaddedCards(from: packFile, progress: progress)
            allUnadded.append(contentsOf: unadded)
        }

        return allUnadded
    }

    // MARK: - Cache Management

    /// Clear all cached data
    func clearCache() {
        manifest = nil
        packCache.removeAll()
        loadError = nil
        AppLogger.packs.info("Content pack cache cleared")
    }
}

// MARK: - Errors

enum ContentPackError: LocalizedError {
    case manifestNotFound
    case manifestDecodingFailed(Error)
    case packNotFound(String)
    case packDecodingFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .manifestNotFound:
            return "Content pack manifest not found in app bundle"
        case .manifestDecodingFailed(let error):
            return "Failed to decode manifest: \(error.localizedDescription)"
        case .packNotFound(let id):
            return "Content pack '\(id)' not found in app bundle"
        case .packDecodingFailed(let id, let error):
            return "Failed to decode pack '\(id)': \(error.localizedDescription)"
        }
    }
}
