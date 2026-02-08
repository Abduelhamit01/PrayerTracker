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
    let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")

    func placeholder(in context: Context) -> NextPrayerLockScreenEntry {
        NextPrayerLockScreenEntry(date: Date(), prayer: "Salah", prayerTime: Date())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> NextPrayerLockScreenEntry {
        NextPrayerLockScreenEntry(date: Date(), prayer: "Salah", prayerTime: Date())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<NextPrayerLockScreenEntry> {
        var entries: [NextPrayerLockScreenEntry] = []

        guard let data = shared?.data(forKey: "widgetPrayerTimes"),
              let times = try? JSONDecoder().decode(PrayerTimes.self, from: data) else {
            // Return placeholder entry when data is not available
            let entry = NextPrayerLockScreenEntry(date: Date(),
                                                  prayer: "Salah",
                                                  prayerTime: Date())
            
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
            let startEntry = NextPrayerLockScreenEntry(date: Calendar.current.startOfDay(for: Date()), prayer: "Fajr", prayerTime: todayFajr)
            entries.append(startEntry)
        }
        
        let schedule = [(start: times.fajr,    label: "Sunrise", target: times.sunrise),
                        (start: times.sunrise, label: "Dhuhr",   target: times.dhuhr),
                        (start: times.dhuhr,   label: "Asr",     target: times.asr),
                        (start: times.asr,     label: "Maghrib", target: times.maghrib),
                        (start: times.maghrib, label: "Isha",    target: times.isha),
        ]
        
        for item in schedule {
            if let startDate = dateFromTimeString(item.start),
               let targetDate = dateFromTimeString(item.target) {
                let entry = NextPrayerLockScreenEntry(date: startDate, prayer: item.label, prayerTime: targetDate)
                entries.append(entry)
            }
        }
        
        if let ishaDate = dateFromTimeString(times.isha) {
            let fajrString = tomorrowTimes?.fajr ?? times.fajr
            if let fajrDate = dateFromTimeString(fajrString),
               let tomorrowFajr = Calendar.current.date(byAdding: .day, value: 1, to: fajrDate) {
                let entry = NextPrayerLockScreenEntry(date: ishaDate, prayer: "Fajr", prayerTime: tomorrowFajr)
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
