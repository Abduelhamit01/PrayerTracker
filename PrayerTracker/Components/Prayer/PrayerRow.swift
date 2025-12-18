//
//  PrayerRow.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 16.12.25.
//

import SwiftUI

struct PrayerRow: View {
    let prayer: Prayer
    @ObservedObject var manager: PrayerManager
    let onPartTap: (String) -> Void
    let onPrayerTap: () -> Void
    
    var body: some View {
        DisclosureGroup {
            VStack(spacing: 20) {
                ForEach(prayer.parts, id: \.self) { part in
                    PrayerPartRow(
                        part: part,
                        isCompleted: manager.isPartCompleted(prayerId: prayer.id, part: part),
                        onTap: { onPartTap(part) }
                    )
                }
            }
        } label: {
            let completedCount = prayer.parts.filter { part in
                manager.isPartCompleted(prayerId: prayer.id, part: part)
            }.count
            
            PrayerHeaderView(
                prayer: prayer,
                completedCount: completedCount,
                isAllCompleted: manager.isAllCompleted(prayer: prayer)
            )
            .onTapGesture(perform: onPrayerTap)
        }
    }
}

#Preview {
    List {
        PrayerRow(
            prayer: Prayer(
                id: "fajr",
                name: "Pflichtgebete",
                parts: ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"],
                emoji: "🕌"
            ),
            manager: PrayerManager(),
            onPartTap: { part in print("Part tapped: \(part)") },
            onPrayerTap: { print("Prayer tapped") }
        )
        .listRowBackground(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

        
        PrayerRow(
            prayer: Prayer(
                id: "Duhr",
                name: "Pflichtgebete",
                parts: ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"],
                emoji: "🕌"
            ),
            manager: PrayerManager(),
            onPartTap: { part in print("Part tapped: \(part)") },
            onPrayerTap: { print("Prayer tapped") }
        )
        .listRowBackground(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

    }
    .listStyle(.plain)
    .listRowSeparator(.hidden)
}
