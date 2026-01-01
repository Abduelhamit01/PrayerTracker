//
//  PrayerHeaderView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 16.12.25.
//

import SwiftUI

struct PrayerHeaderView: View {
    let prayer: Prayer
    let completedCount: Int
    let isAllCompleted: Bool
    
    var body: some View {
        HStack(spacing: 30) {
            Text(prayer.emoji)
                .font(.system(size: 50))
            VStack {
                Text(prayer.name)
                    .foregroundStyle(.primary)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("\(completedCount) von \(prayer.parts.count) erledigt")
            }
            Spacer()
            CheckMarkImage(isCompleted: isAllCompleted)
        }
        .padding(.vertical, 10)
    }
}

#Preview("All Completed") {
    PrayerHeaderView(
        prayer: Prayer(
            id: "fajr",
            name: "Pflichtgebete",
            parts: ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"],
            emoji: "🕌",
        ),
        completedCount: 5,
        isAllCompleted: true
    )
    .padding()
}

#Preview("Partially Completed") {
    PrayerHeaderView(
        prayer: Prayer(
            id: "fajr",
            name: "Pflichtgebete",
            parts: ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"],
            emoji: "🕌",
        ),
        completedCount: 2,
        isAllCompleted: false
    )
    .padding()
}
