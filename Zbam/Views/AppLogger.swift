import OSLog

/// Centralized logging for the Zbam app
enum AppLogger {
    /// General app events and navigation
    static let general = Logger(subsystem: "com.zbam.app", category: "general")
    
    /// Card-related operations (create, edit, delete, swipe)
    static let cards = Logger(subsystem: "com.zbam.app", category: "cards")
    
    /// Data persistence operations
    static let data = Logger(subsystem: "com.zbam.app", category: "data")
    
    /// UI interactions and state changes
    static let ui = Logger(subsystem: "com.zbam.app", category: "ui")
    
    /// Errors and crashes
    static let error = Logger(subsystem: "com.zbam.app", category: "error")

    /// Content pack operations (loading, browsing)
    static let packs = Logger(subsystem: "com.zbam.app", category: "packs")

    /// AI suggestions and recommendations
    static let suggestions = Logger(subsystem: "com.zbam.app", category: "suggestions")
}
