//
//  PrayerTrackerApp.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 24.11.25.
//

import SwiftUI

@main
struct PrayerTrackerApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("appAppearance") private var appearance: String = "System"

    private var colorScheme: ColorScheme? {
        switch appearance {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil  // System
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenWelcome {
                    ContentView()
                } else {
                    WelcomePage(onComplete: {
                        hasSeenWelcome = true
                    })
                }
            }
            .preferredColorScheme(colorScheme)
        }
    }
}
