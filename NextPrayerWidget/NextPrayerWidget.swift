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
            prayerName: "Maghrib",
            prayerTime: Date().addingTimeInterval(3600),
            location: "Bergisch Gladbach"
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
        
        // Karte 1: Ab Fajr → zeig Countdown bis Sunrise
        let fajrStart = dateFromTimeString(times.fajr)!
        let sunriseTarget = dateFromTimeString(times.sunrise)!
        entries.append(SimpleEntry(date: fajrStart, prayerName: "Sunrise", prayerTime: sunriseTarget, location: cityName))

        // Karte 2: Ab Sunrise → zeig Countdown bis Dhuhr
        let sunriseStart = dateFromTimeString(times.sunrise)!
        let dhuhrTarget = dateFromTimeString(times.dhuhr)!
        entries.append(SimpleEntry(date: sunriseStart, prayerName: "Dhuhr", prayerTime: dhuhrTarget, location: cityName))

        // Karte 3: Ab Dhuhr → zeig Countdown bis Asr
        let dhuhrStart = dateFromTimeString(times.dhuhr)!
        let asrTarget = dateFromTimeString(times.asr)!
        entries.append(SimpleEntry(date: dhuhrStart, prayerName: "Asr", prayerTime: asrTarget, location: cityName))

        // Karte 4: Ab Asr → zeig Countdown bis Maghrib
        let asrStart = dateFromTimeString(times.asr)!
        let maghribTarget = dateFromTimeString(times.maghrib)!
        entries.append(SimpleEntry(date: asrStart, prayerName: "Maghrib", prayerTime: maghribTarget, location: cityName))

        // Karte 5: Ab Maghrib → zeig Countdown bis Isha
        let maghribStart = dateFromTimeString(times.maghrib)!
        let ishaTarget = dateFromTimeString(times.isha)!
        entries.append(SimpleEntry(date: maghribStart, prayerName: "Isha", prayerTime: ishaTarget, location: cityName))

        // Karte 6: Ab Isha → zeig Countdown bis Fajr (MORGEN, mit echten morgigen Zeiten)
        let ishaStart = dateFromTimeString(times.isha)!
        let tomorrowFajrString = tomorrowTimes?.fajr ?? times.fajr  // Morgige Fajr-Zeit, Fallback: heutige
        let tomorrowFajrTarget = Calendar.current.date(byAdding: .day, value: 1, to: dateFromTimeString(tomorrowFajrString)!)!
        entries.append(SimpleEntry(date: ishaStart, prayerName: "Fajr", prayerTime: tomorrowFajrTarget, location: cityName))
        
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
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryCircular])
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
