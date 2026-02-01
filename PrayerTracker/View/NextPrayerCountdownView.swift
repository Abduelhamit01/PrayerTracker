//
//  NextPrayerCountdownView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 29.01.26.
//

import SwiftUI
import Combine

struct NextPrayerCountdownView: View {
    @ObservedObject var prayerTimeManager: PrayerTimeManager

    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var nextPrayerInfo: (id: String, name: String, time: String, remaining: TimeInterval)? {
        guard let times = prayerTimeManager.todaysTimes else { return nil }

        let prayers: [(id: String, name: String, time: String)] = [
            ("fajr", "Fajr", times.fajr),
            ("dhuhr", "Dhuhr", times.dhuhr),
            ("asr", "Asr", times.asr),
            ("maghrib", "Maghrib", times.maghrib),
            ("isha", "Isha", times.isha)
        ]

        for prayer in prayers {
            if let prayerDate = dateFromTimeString(prayer.time), prayerDate > now {
                return (prayer.id, prayer.name, prayer.time, prayerDate.timeIntervalSince(now))
            }
        }

        // Alle Gebete vorbei - zeige Fajr von morgen
        if let fajrTime = dateFromTimeString(times.fajr) {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: fajrTime)!
            return ("fajr", "Fajr", times.fajr, tomorrow.timeIntervalSince(now))
        }

        return nil
    }

    var body: some View {
        Group {
            if let info = nextPrayerInfo, info.remaining > 0 {
                VStack(spacing: 4) {
                    Text(localizedPrayerName(info.id))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(formattedTime(info.remaining))
                        .font(.system(size: 42, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .onReceive(timer) { _ in
            now = Date()
        }
    }

    // MARK: - Formatted Time

    private func formattedTime(_ timeRemaining: TimeInterval) -> String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    // MARK: - Helper

    private func dateFromTimeString(_ time: String) -> Date? {
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

    private func localizedPrayerName(_ id: String) -> LocalizedStringKey {
        switch id {
        case "fajr": return "fajr"
        case "dhuhr": return "dhuhr"
        case "asr": return "asr"
        case "maghrib": return "maghrib"
        case "isha": return "isha"
        default: return "fajr"
        }
    }
}

#Preview {
    VStack {
        NextPrayerCountdownView(prayerTimeManager: PrayerTimeManager())
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
