//
//  NextPrayerWidget.swift
//  NextPrayerWidget
//
//  Created by Abdülhamit Oral on 07.02.26.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")

    var cityName: String {
        shared?.string(forKey: "widgetCityName") ?? "-"
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), prayerName: "Salah", prayerTime: Date(), location: cityName)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        return SimpleEntry(
            date: Date(),
            prayerName: "Salah",
            prayerTime: Date().addingTimeInterval(3600),
            location: cityName
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        guard let data = shared?.data(forKey: "widgetPrayerTimes"),
              let times = try? JSONDecoder().decode(PrayerTimes.self, from: data) else {
            // Return placeholder entry when data is not available
            let entry = SimpleEntry(date: Date(),
                                    prayerName: "PrayerName",
                                    prayerTime: Date(),
                                    location: cityName)
            
            return Timeline(entries: [entry], policy: .atEnd)
        }
        
        let tomorrowTimes: PrayerTimes? = {
            guard let data = shared?.data(forKey: "widgetTomorrowPrayerTimes"),
                  let times = try? JSONDecoder().decode(PrayerTimes.self, from: data) else {
                return nil
            }
            return times
        }()
        
        if let todayFajr = dateFromTimeString(times.fajr) {
            let startEntry = SimpleEntry(date: Calendar.current.startOfDay(for: Date()), prayerName: "fajr", prayerTime: todayFajr, location: cityName)
            entries.append(startEntry)
        }

        let schedules = [(start: times.fajr, label: "sunrise", target: times.sunrise),
                         (start: times.sunrise, label: "dhuhr", target: times.dhuhr),
                         (start: times.dhuhr, label: "asr", target: times.asr),
                         (start: times.asr, label: "maghrib", target: times.maghrib),
                         (start: times.maghrib, label: "isha", target: times.isha),
        ]

        for item in schedules {
            if let start = dateFromTimeString(item.start),
               let target = dateFromTimeString(item.target) {
                let entry = SimpleEntry(date: start, prayerName: item.label, prayerTime: target, location: cityName)
                entries.append(entry)
            }
        }

        if let ishaDate = dateFromTimeString(times.isha) {
            let fajrString = tomorrowTimes?.fajr ?? times.fajr
            if let fajrDate = dateFromTimeString(fajrString),
               let tomorrowFajr = Calendar.current.date(byAdding: .day, value: 1, to: fajrDate) {
                let entry = SimpleEntry(date: ishaDate, prayerName: "fajr", prayerTime: tomorrowFajr, location: cityName)
                entries.append(entry)
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

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let prayerName: String
    let prayerTime: Date
    let location: String
}

struct NextPrayerWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme

    private var widgetBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.0, green: 0.22, blue: 0.10)  // Dunkles Islamic Green
            : Color(red: 0.85, green: 0.95, blue: 0.85)  // Helles Islamic Green
    }

    var body: some View {
        if widgetFamily == .accessoryCircular {
            ZStack {
                AccessoryWidgetBackground()
                    .opacity(0.7)
                VStack(spacing: 2) {
                    Text(entry.prayerName)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text(entry.prayerTime, style: .timer)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                }
            }
        } else {
        VStack(alignment: .center) {
            Text(entry.location)
                .font(.system(.footnote, design: .rounded, weight: .semibold))
                .textCase(.uppercase)
            Spacer()
            Text("Until \(entry.prayerName)")
                .font(.system(.body, design: .rounded, weight: .medium))
            Text(entry.prayerTime, style: .timer)
                .font(.system(.title, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
            Spacer()
            Text(entry.prayerTime, style: .time)
                .font(.system(.body, design: .rounded, weight: .semibold))
            }
            .dynamicTypeSize(...DynamicTypeSize.large)
        }
    }
}

private struct WidgetBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        colorScheme == .dark
            ? Color(red: 0.0, green: 0.22, blue: 0.10)  // Dunkles Islamic Green
            : Color(red: 0.85, green: 0.95, blue: 0.85)  // Helles Islamic Green
    }
}

struct NextPrayerWidget: Widget {
    let kind: String = "NextPrayerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            NextPrayerWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetBackgroundView()
                }
        }
        .supportedFamilies([.systemSmall, .accessoryCircular])
    }
}

#Preview(as: .systemSmall) {
    NextPrayerWidget()
} timeline: {
    let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")
    let cityName = shared?.string(forKey: "widgetCityName") ?? "-"
    
    SimpleEntry(date: Date(), prayerName: "-", prayerTime: Date(), location: cityName)
}

#Preview(as: .accessoryCircular) {
    NextPrayerWidget()
} timeline: {
    let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")
    let cityName = shared?.string(forKey: "widgetCityName") ?? "-"
    
    SimpleEntry(date: Date(), prayerName: "Salah", prayerTime: Date(), location: cityName)
    SimpleEntry(date: Date(), prayerName: "Salah", prayerTime: Date(), location: cityName)
}
