//
//  PrayerTrackerApp.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 24.11.25.
//

import SwiftUI

@main
struct PrayerTrackerApp: App {
    @AppStorage("appAppearance") private var appearanceRaw: String = AppAppearance.system.rawValue

    private var colorScheme: ColorScheme? {
        let appearance = AppAppearance(rawValue: appearanceRaw) ?? .system
        return appearance.colorScheme
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(colorScheme)
        }
    }
}
