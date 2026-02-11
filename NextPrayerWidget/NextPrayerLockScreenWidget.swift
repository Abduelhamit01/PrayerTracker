//
//  NextPrayerLockScreenWidget.swift
//  NextPrayerWidgetExtension
//
//  Created by Abdülhamit Oral on 08.02.26.
//

import WidgetKit
import SwiftUI

struct NextPrayerLockScreenEntry: TimelineEntry {
    let date: Date
    let prayer: String
    let prayerTime: Date
}

struct NextPrayerLockScreenProvider: AppIntentTimelineProvider {

    func placeholder(in context: Context) -> NextPrayerLockScreenEntry {
        NextPrayerLockScreenEntry(date: Date(), prayer: "Salah", prayerTime: Date())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> NextPrayerLockScreenEntry {
        NextPrayerLockScreenEntry(date: Date(), prayer: "Salah", prayerTime: Date())
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<NextPrayerLockScreenEntry> {
        var entries: [NextPrayerLockScreenEntry] = []
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        // Dynamisch aus dem Monats-Array nachschlagen
        let todayTimes = WidgetPrayerTimesHelper.times(for: today)
        let tomorrowTimes = WidgetPrayerTimesHelper.times(for: tomorrow)

        guard let times = todayTimes else {
            let entry = NextPrayerLockScreenEntry(date: today, prayer: "Salah", prayerTime: today)
            return Timeline(entries: [entry], policy: .atEnd)
        }

        // --- Heute ---
        if let todayFajr = WidgetPrayerTimesHelper.dateFromTimeString(times.fajr, on: today) {
            entries.append(NextPrayerLockScreenEntry(date: calendar.startOfDay(for: today), prayer: "fajr", prayerTime: todayFajr))
        }

        let todaySchedule = [
            (start: times.fajr,    label: "sunrise", target: times.sunrise),
            (start: times.sunrise, label: "dhuhr",   target: times.dhuhr),
            (start: times.dhuhr,   label: "asr",     target: times.asr),
            (start: times.asr,     label: "maghrib", target: times.maghrib),
            (start: times.maghrib, label: "isha",    target: times.isha),
        ]

        for item in todaySchedule {
            if let startDate = WidgetPrayerTimesHelper.dateFromTimeString(item.start, on: today),
               let targetDate = WidgetPrayerTimesHelper.dateFromTimeString(item.target, on: today) {
                entries.append(NextPrayerLockScreenEntry(date: startDate, prayer: item.label, prayerTime: targetDate))
            }
        }

        // --- Nach Isha: Countdown auf morgen Fajr ---
        let tomorrowFajrString = (tomorrowTimes ?? times).fajr
        if let ishaDate = WidgetPrayerTimesHelper.dateFromTimeString(times.isha, on: today),
           let tomorrowFajr = WidgetPrayerTimesHelper.dateFromTimeString(tomorrowFajrString, on: tomorrow) {
            entries.append(NextPrayerLockScreenEntry(date: ishaDate, prayer: "fajr", prayerTime: tomorrowFajr))
        }

        // --- Morgen (damit Widget auch nach Tageswechsel korrekt ist) ---
        if let tomorrowTimes {
            if let tomorrowFajr = WidgetPrayerTimesHelper.dateFromTimeString(tomorrowTimes.fajr, on: tomorrow) {
                entries.append(NextPrayerLockScreenEntry(date: calendar.startOfDay(for: tomorrow), prayer: "fajr", prayerTime: tomorrowFajr))
            }

            let tomorrowSchedule = [
                (start: tomorrowTimes.fajr,    label: "sunrise", target: tomorrowTimes.sunrise),
                (start: tomorrowTimes.sunrise, label: "dhuhr",   target: tomorrowTimes.dhuhr),
                (start: tomorrowTimes.dhuhr,   label: "asr",     target: tomorrowTimes.asr),
                (start: tomorrowTimes.asr,     label: "maghrib", target: tomorrowTimes.maghrib),
                (start: tomorrowTimes.maghrib, label: "isha",    target: tomorrowTimes.isha),
            ]

            for item in tomorrowSchedule {
                if let startDate = WidgetPrayerTimesHelper.dateFromTimeString(item.start, on: tomorrow),
                   let targetDate = WidgetPrayerTimesHelper.dateFromTimeString(item.target, on: tomorrow) {
                    entries.append(NextPrayerLockScreenEntry(date: startDate, prayer: item.label, prayerTime: targetDate))
                }
            }
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct NextPrayerLockScreenEntryView : View {
    var entry: NextPrayerLockScreenProvider.Entry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
                .opacity(0.7)
            VStack(spacing: 2) {
                Text(entry.prayer)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(entry.prayerTime, style: .time)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct NextPrayerLockScreenWidget: Widget {
    let kind: String = "NextPrayerLockScreenWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: NextPrayerLockScreenProvider()) { entry in
            NextPrayerLockScreenEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.accessoryCircular])
    }
}


#Preview(as: .accessoryCircular) {
    NextPrayerLockScreenWidget()
} timeline: {
    NextPrayerLockScreenEntry(date: Date(), prayer: "Salah", prayerTime: Date())
}
