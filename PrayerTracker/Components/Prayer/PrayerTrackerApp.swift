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

    var body: some Scene {
        WindowGroup {
            if hasSeenWelcome {
                ContentView()
            } else {
                WelcomePage(onComplete: {
                    hasSeenWelcome = true
                })
            }
        }
    }
}
