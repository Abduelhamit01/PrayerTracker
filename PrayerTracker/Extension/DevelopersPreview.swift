//
//  DevelopersPreview.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 16.12.25.
//

import SwiftUI

#if DEBUG
extension Prayer {
    static var mockPflichtgebete: Prayer {
        Prayer(
            id: "fajr",
            name: "Sunnah-Gebete",
            parts: ["2 Rak'ah vor Fajr", "4 Rak'ah vor Dhuhr"],
            emoji: "🤲"
        )
    }
    
    static var mockSunna: Prayer {
        Prayer(
            id: "fajr",
            name: "Sunnah-Gebete",
            parts: ["2 Rak'ah vor Fajr", "4 Rak'ah vor Dhuhr"],
            emoji: "🤲"
        )
    }
}

extension PrayerManager {
    static var mockWithCompletions: PrayerManager {
        let manager = PrayerManager()
        // Setze einige Gebete als erledigt für Preview
        if let prayer = manager.prayers.first {
            manager.togglePartCompletion(prayerId: prayer.id, part: prayer.parts.first ?? "")
        }
        return manager
    }
}
#endif
