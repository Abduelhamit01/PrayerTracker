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
}

struct AllPrayerTimesProvider: AppIntentTimelineProvider {
    let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")

    var cityName: String {
        shared?.string(forKey: "widgetCityName") ?? "-"
    }
    
    func placeholder(in context: Context) -> AllPrayerTimesEntry {
        AllPrayerTimesEntry(date: Date(), times: .placeholder, location: cityName)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> AllPrayerTimesEntry {
        AllPrayerTimesEntry(date: Date(), times: .placeholder, location: cityName)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<AllPrayerTimesEntry> {
        var entries: [AllPrayerTimesEntry] = []
        
        let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")
        let cityName = shared?.string(forKey: "widgetCityName") ?? "-"
        
        guard let data = shared?.data(forKey: "widgetPrayerTimes"),
              let times = try? JSONDecoder().decode(PrayerTimes.self, from: data) else {
            let entry = AllPrayerTimesEntry(date: Date(), times: .placeholder, location: cityName)

            return Timeline(entries: [entry], policy: .atEnd)
        }
        
        entries.append(AllPrayerTimesEntry(date: Date(), times: times, location: cityName))
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct AllPrayerTimesWidgetEntryView : View {
    var entry: AllPrayerTimesProvider.Entry
    
    var body: some View {
        VStack() {
            Text(entry.location)
                .font(.footnote)
                .textCase(.uppercase)
            Spacer()
            VStack {
                HStack{
                    Text("Fajr")
                    Spacer()
                    Text(entry.times?.fajr ?? "-")
                }
                HStack{
                    Text("Sunrise")
                    Spacer()
                    Text(entry.times?.sunrise ?? "-")
                }
                HStack{
                    Text("Dhuhr")
                    Spacer()
                    Text(entry.times?.dhuhr ?? "-")
                }
                HStack{
                    Text("Asr")
                    Spacer()
                    Text(entry.times?.asr ?? "-")
                }
                HStack{
                    Text("Maghrib")
                    Spacer()
                    Text(entry.times?.maghrib ?? "-")
                }
                HStack{
                    Text("Isha")
                    Spacer()
                    Text(entry.times?.isha ?? "-")
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.large)
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    AllPrayerTimesWidget()
} timeline: {
    AllPrayerTimesEntry(date: Date(), times: .placeholder, location: "Standort")
}
