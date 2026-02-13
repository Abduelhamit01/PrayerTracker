//
//  AllPrayerTimesWidget.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 07.02.26.
//

import WidgetKit
import SwiftUI

struct AllPrayerTimesEntry: TimelineEntry {
    let date: Date
    let times: PrayerTimes?
    let location: String
    let currentPrayer: String?
}

struct AllPrayerTimesProvider: AppIntentTimelineProvider {

    func placeholder(in context: Context) -> AllPrayerTimesEntry {
        AllPrayerTimesEntry(date: Date(), times: .placeholder, location: WidgetPrayerTimesHelper.cityName, currentPrayer: "fajr")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> AllPrayerTimesEntry {
        AllPrayerTimesEntry(date: Date(), times: .placeholder, location: WidgetPrayerTimesHelper.cityName, currentPrayer: "fajr")
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<AllPrayerTimesEntry> {
        var entries: [AllPrayerTimesEntry] = []
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let cityName = WidgetPrayerTimesHelper.cityName

        // Dynamisch aus dem Monats-Array nachschlagen
        let todayTimes = WidgetPrayerTimesHelper.times(for: today)
        let tomorrowTimes = WidgetPrayerTimesHelper.times(for: tomorrow)

        guard let times = todayTimes else {
            let entry = AllPrayerTimesEntry(date: today, times: .placeholder, location: cityName, currentPrayer: nil)
            return Timeline(entries: [entry], policy: .atEnd)
        }

        // --- Heute ---
        let todayPrayers = [
            (id: "fajr", time: times.fajr),
            (id: "dhuhr", time: times.dhuhr),
            (id: "asr", time: times.asr),
            (id: "maghrib", time: times.maghrib),
            (id: "isha", time: times.isha)
        ]

        for prayer in todayPrayers {
            if let startDate = WidgetPrayerTimesHelper.dateFromTimeString(prayer.time, on: today) {
                entries.append(AllPrayerTimesEntry(
                    date: startDate,
                    times: times, location: cityName, currentPrayer: prayer.id
                ))
            }
        }

        // --- Mitternacht: Tageswechsel → morgen-Zeiten zeigen ---
        if let tomorrowTimes {
            var midnightComponents = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            midnightComponents.hour = 0
            midnightComponents.minute = 0
            midnightComponents.second = 0
            if let midnight = calendar.date(from: midnightComponents) {
                entries.append(AllPrayerTimesEntry(
                    date: midnight,
                    times: tomorrowTimes,
                    location: cityName,
                    currentPrayer: nil
                ))
            }
        }

        // --- Morgen (damit Widget auch nach Tageswechsel korrekt ist) ---
        if let tomorrowTimes {
            let tomorrowPrayers = [
                (id: "fajr", time: tomorrowTimes.fajr),
                (id: "dhuhr", time: tomorrowTimes.dhuhr),
                (id: "asr", time: tomorrowTimes.asr),
                (id: "maghrib", time: tomorrowTimes.maghrib),
                (id: "isha", time: tomorrowTimes.isha)
            ]

            for prayer in tomorrowPrayers {
                if let startDate = WidgetPrayerTimesHelper.dateFromTimeString(prayer.time, on: tomorrow) {
                    entries.append(AllPrayerTimesEntry(
                        date: startDate,
                        times: tomorrowTimes, location: cityName, currentPrayer: prayer.id
                    ))
                }
            }
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct AllPrayerTimesWidgetEntryView : View {
    var entry: AllPrayerTimesProvider.Entry
    @Environment(\.colorScheme) var colorScheme

    private var borderColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        VStack(spacing: 1) {
            Text(entry.location)
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .textCase(.uppercase)
                .padding(.top)
            Spacer()
            VStack(spacing: 4) {
                prayerRow(icon: "sunrise.fill", id: "fajr", time: entry.times?.fajr)
                prayerRow(icon: "sun.max.fill", id: "dhuhr", time: entry.times?.dhuhr)
                prayerRow(icon: "sun.min.fill", id: "asr", time: entry.times?.asr)
                prayerRow(icon: "sunset.fill", id: "maghrib", time: entry.times?.maghrib)
                prayerRow(icon: "moon.stars.fill", id: "isha", time: entry.times?.isha)
            }
            .padding(.bottom)
        }
        .dynamicTypeSize(...DynamicTypeSize.large)
    }

    private func prayerRow(icon: String, id: String, time: String?) -> some View {
        let isCurrent = entry.currentPrayer == id
        return HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .frame(width: 14)
            Text(LocalizedStringKey(id))
                .font(.system(.caption, design: .rounded, weight: isCurrent ? .bold : .medium))
            Spacer()
            Text(time ?? "-")
                .font(.system(.caption, design: .rounded, weight: isCurrent ? .bold : .semibold))
                .monospacedDigit()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isCurrent ? borderColor.opacity(0.5) : .clear, lineWidth: 1)
        )
    }
}

private struct AllPrayerWidgetBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        colorScheme == .dark
            ? Color(red: 0.0, green: 0.22, blue: 0.10)
            : Color(red: 0.85, green: 0.95, blue: 0.85)
    }
}

struct AllPrayerTimesWidget: Widget {
    let kind: String = "All"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: AllPrayerTimesProvider()) { entry in
            AllPrayerTimesWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    AllPrayerWidgetBackgroundView()
                }
        }
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    AllPrayerTimesWidget()
} timeline: {
    AllPrayerTimesEntry(date: Date(), times: .placeholder, location: "Standort", currentPrayer: "dhuhr")
}
