
import SwiftUI
import SwiftData
import OSLog

@main
struct FlickardApp: App {
    @AppStorage("darkMode") private var darkMode: Bool = false
    
    init() {
        // Log app launch with device info
        AppLogger.general.info("App launched")
        AppLogger.general.info("iOS Version: \(UIDevice.current.systemVersion)")
        AppLogger.general.info("Device Model: \(UIDevice.current.model)")
        AppLogger.general.info("Device Name: \(UIDevice.current.name)")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(darkMode ? .dark : .light)
        }
        .modelContainer(for: [Card.self, UserPackProgress.self])
    }
}
