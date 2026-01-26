//
//  ZbamApp.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 16.01.26.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct ZbamApp: App {
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
