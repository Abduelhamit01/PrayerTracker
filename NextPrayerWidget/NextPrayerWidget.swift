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
        SimpleEntry(date: Date(), prayerName: "Salah", prayerTime: Date(), location: WidgetPrayerTimesHelper.cityName)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), prayerName: "Salah", prayerTime: Date().addingTimeInterval(3600), location: WidgetPrayerTimesHelper.cityName)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let cityName = WidgetPrayerTimesHelper.cityName

        // Dynamisch aus dem Monats-Array nachschlagen
        let todayTimes = WidgetPrayerTimesHelper.times(for: today)
        let tomorrowTimes = WidgetPrayerTimesHelper.times(for: tomorrow)

        guard let times = todayTimes else {
            let entry = SimpleEntry(date: today, prayerName: "PrayerName", prayerTime: today, location: cityName)
            return Timeline(entries: [entry], policy: .atEnd)
        }

        // --- Heute ---
        if let todayFajr = WidgetPrayerTimesHelper.dateFromTimeString(times.fajr, on: today) {
            entries.append(SimpleEntry(date: calendar.startOfDay(for: today), prayerName: "fajr", prayerTime: todayFajr, location: cityName))
        }

        let todaySchedules = [
            (start: times.fajr, label: "sunrise", target: times.sunrise),
            (start: times.sunrise, label: "dhuhr", target: times.dhuhr),
            (start: times.dhuhr, label: "asr", target: times.asr),
            (start: times.asr, label: "maghrib", target: times.maghrib),
            (start: times.maghrib, label: "isha", target: times.isha),
        ]

        for item in todaySchedules {
            if let start = WidgetPrayerTimesHelper.dateFromTimeString(item.start, on: today),
               let target = WidgetPrayerTimesHelper.dateFromTimeString(item.target, on: today) {
                entries.append(SimpleEntry(date: start, prayerName: item.label, prayerTime: target, location: cityName))
            }
        }

        // --- Nach Isha: Countdown auf morgen Fajr ---
        let tomorrowFajrString = (tomorrowTimes ?? times).fajr
        if let ishaDate = WidgetPrayerTimesHelper.dateFromTimeString(times.isha, on: today),
           let tomorrowFajr = WidgetPrayerTimesHelper.dateFromTimeString(tomorrowFajrString, on: tomorrow) {
            entries.append(SimpleEntry(date: ishaDate, prayerName: "fajr", prayerTime: tomorrowFajr, location: cityName))
        }

        // --- Morgen (damit Widget auch nach Tageswechsel korrekt ist) ---
        if let tomorrowTimes {
            if let tomorrowFajr = WidgetPrayerTimesHelper.dateFromTimeString(tomorrowTimes.fajr, on: tomorrow) {
                entries.append(SimpleEntry(date: calendar.startOfDay(for: tomorrow), prayerName: "fajr", prayerTime: tomorrowFajr, location: cityName))
            }

            let tomorrowSchedules = [
                (start: tomorrowTimes.fajr, label: "sunrise", target: tomorrowTimes.sunrise),
                (start: tomorrowTimes.sunrise, label: "dhuhr", target: tomorrowTimes.dhuhr),
                (start: tomorrowTimes.dhuhr, label: "asr", target: tomorrowTimes.asr),
                (start: tomorrowTimes.asr, label: "maghrib", target: tomorrowTimes.maghrib),
                (start: tomorrowTimes.maghrib, label: "isha", target: tomorrowTimes.isha),
            ]

            for item in tomorrowSchedules {
                if let start = WidgetPrayerTimesHelper.dateFromTimeString(item.start, on: tomorrow),
                   let target = WidgetPrayerTimesHelper.dateFromTimeString(item.target, on: tomorrow) {
                    entries.append(SimpleEntry(date: start, prayerName: item.label, prayerTime: target, location: cityName))
                }
            }
        }

        return Timeline(entries: entries, policy: .atEnd)
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
