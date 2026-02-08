//
//  NextPrayerWidget.swift
//  NextPrayerWidget
//
//  Created by Abdülhamit Oral on 07.02.26.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")
        let cityName = shared?.string(forKey: "widgetCityName") ?? "-"
        
        return SimpleEntry(date: Date(), prayerName: "Salah", prayerTime: Date(), location: cityName)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")
        let cityName = shared?.string(forKey: "widgetCityName") ?? "-"
        
        return SimpleEntry(
            date: Date(),
            prayerName: "Salah",
            prayerTime: Date().addingTimeInterval(3600),
            location: cityName
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
                
        let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")
        let cityName = shared?.string(forKey: "widgetCityName") ?? "-"

        
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
            let startEntry = SimpleEntry(date: Calendar.current.startOfDay(for: Date()), prayerName: "Fajr", prayerTime: todayFajr, location: cityName)
            entries.append(startEntry)
        }
        
        let schedules = [(start: times.fajr, label: "Sunrise", target: times.sunrise),
                         (start: times.sunrise, label: "Dhuhr", target: times.dhuhr),
                         (start: times.dhuhr, label: "Asr", target: times.asr),
                         (start: times.asr, label: "Maghrib", target: times.maghrib),
                         (start: times.maghrib, label: "Isha", target: times.isha),
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
                let entry = SimpleEntry(date: ishaDate, prayerName: "Fajr", prayerTime: tomorrowFajr, location: cityName)
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
                .font(.footnote)
                .textCase(.uppercase)
            Spacer()
            Text("Until \(entry.prayerName)")
            Text(entry.prayerTime, style: .timer)
                .multilineTextAlignment(.center)
            Spacer()
            Text(entry.prayerTime, style: .time)
            }
        }
    }
}

struct NextPrayerWidget: Widget {
    let kind: String = "NextPrayerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            NextPrayerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
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
