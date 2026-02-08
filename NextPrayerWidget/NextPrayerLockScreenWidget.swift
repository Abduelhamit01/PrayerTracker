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
        let entry = NextPrayerLockScreenEntry(date: Date(), prayer: "Salah", prayerTime: Date())
        let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")

        
        
        return Timeline(entries: [entry], policy: .atEnd)
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
