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
    let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")

    var cityName: String {
        shared?.string(forKey: "widgetCityName") ?? "-"
    }

    func placeholder(in context: Context) -> AllPrayerTimesEntry {
        AllPrayerTimesEntry(date: Date(), times: .placeholder, location: cityName, currentPrayer: "fajr")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> AllPrayerTimesEntry {
        AllPrayerTimesEntry(date: Date(), times: .placeholder, location: cityName, currentPrayer: "fajr")
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<AllPrayerTimesEntry> {
        var entries: [AllPrayerTimesEntry] = []

        let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")
        let cityName = shared?.string(forKey: "widgetCityName") ?? "-"

        guard let data = shared?.data(forKey: "widgetPrayerTimes"),
              let times = try? JSONDecoder().decode(PrayerTimes.self, from: data) else {
            let entry = AllPrayerTimesEntry(date: Date(), times: .placeholder, location: cityName, currentPrayer: nil)
            return Timeline(entries: [entry], policy: .atEnd)
        }

        // Für jedes Gebet einen Entry: Gebet bleibt markiert bis das nächste beginnt
        let prayers = [
            (id: "fajr", time: times.fajr),
            (id: "dhuhr", time: times.dhuhr),
            (id: "asr", time: times.asr),
            (id: "maghrib", time: times.maghrib),
            (id: "isha", time: times.isha)
        ]

        for prayer in prayers {
            if let startDate = dateFromTimeString(prayer.time) {
                entries.append(AllPrayerTimesEntry(
                    date: startDate,
                    times: times, location: cityName, currentPrayer: prayer.id
                ))
            }
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    func dateFromTimeString(_ time: String) -> Date? {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        return calendar.date(from: dateComponents)
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
                prayerRow(icon: "sunrise.fill", id: "fajr", name: "Fajr", time: entry.times?.fajr)
                prayerRow(icon: "sun.max.fill", id: "dhuhr", name: "Dhuhr", time: entry.times?.dhuhr)
                prayerRow(icon: "sun.min.fill", id: "asr", name: "Asr", time: entry.times?.asr)
                prayerRow(icon: "sunset.fill", id: "maghrib", name: "Maghrib", time: entry.times?.maghrib)
                prayerRow(icon: "moon.stars.fill", id: "isha", name: "Isha", time: entry.times?.isha)
            }
            .padding(.bottom)
        }
        .dynamicTypeSize(...DynamicTypeSize.large)
    }

    private func prayerRow(icon: String, id: String, name: String, time: String?) -> some View {
        let isCurrent = entry.currentPrayer == id
        return HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .frame(width: 14)
            Text(name)
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
