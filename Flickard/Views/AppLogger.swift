import OSLog

/// Centralized logging for the flickard app
enum AppLogger {
    /// General app events and navigation
    static let general = Logger(subsystem: "com.flickard.app", category: "general")
    
    /// Card-related operations (create, edit, delete, swipe)
    static let cards = Logger(subsystem: "com.flickard.app", category: "cards")
    
    /// Data persistence operations
    static let data = Logger(subsystem: "com.flickard.app", category: "data")
    
    /// UI interactions and state changes
    static let ui = Logger(subsystem: "com.flickard.app", category: "ui")
    
    /// Errors and crashes
    static let error = Logger(subsystem: "com.flickard.app", category: "error")

    /// Content pack operations (loading, browsing)
    static let packs = Logger(subsystem: "com.flickard.app", category: "packs")

    /// AI suggestions and recommendations
    static let suggestions = Logger(subsystem: "com.flickard.app", category: "suggestions")
}
