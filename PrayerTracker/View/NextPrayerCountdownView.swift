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
    @Environment(\.colorScheme) var colorScheme

    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    /// Morgige Fajr-Zeit direkt vom Manager
    private var tomorrowFajrTime: String? {
        prayerTimeManager.tomorrowTimes?.fajr
    }
    
    ///Morgige Sunrise-Zeit direkt vom Manager
    private var tomorrowSunriseTime: String? {
        prayerTimeManager.tomorrowTimes?.sunrise
    }

    /// Ob wir nach Isha sind und auf Fajr von morgen warten
    private var isAfterIsha: Bool {
        guard let times = prayerTimeManager.todaysTimes,
              let ishaDate = dateFromTimeString(times.isha) else { return false }
        return now >= ishaDate
    }

    private var nextPrayerInfo: (id: String, name: String, time: String, remaining: TimeInterval)? {
        guard let times = prayerTimeManager.todaysTimes else { return nil }

        let prayers: [(id: String, name: String, time: String)] = [
            ("fajr", "Fajr", times.fajr),
            ("sunrise", "Sunrise", times.sunrise),
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
        let fajrString = tomorrowFajrTime ?? times.fajr
        if let fajrTime = dateFromTimeString(fajrString) {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: fajrTime)!
            return ("fajr", "Fajr", fajrString, tomorrow.timeIntervalSince(now))
        }

        return nil
    }
    
    private var prayerIcon: String {
        guard let info = nextPrayerInfo else { return "moon.stars.fill" }
        switch info.id {
        case "fajr": return "sunrise.fill"
        case "sunrise": return "sun.horizon.fill"
        case "dhuhr": return "sun.max.fill"
        case "asr": return "sun.min.fill"
        case "maghrib": return "sunset.fill"
        case "isha": return "moon.stars.fill"
        default: return "moon.stars.fill"
        }
    }

    var body: some View {
        Group {
            if let info = nextPrayerInfo, info.remaining > 0 {
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Text(String(localized: "until"))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1.0)

                        Text(localizedPrayerName(info.id))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1.0)

                        Image(systemName: prayerIcon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.islamicGreen)
                    }
                    
                    Text(formattedTime(info.remaining))
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.islamicGreen, .islamicGreen.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    if info.id == "fajr" {
                        VStack {
                            if isAfterIsha, let tomorrowFajr = tomorrowFajrTime {
                                // Nach Isha: morgige Fajr-Uhrzeit anzeigen
                                HStack(spacing: 4) {
                                    Image(systemName: "sunrise")
                                        .font(.system(size: 11))
                                    Text(String(localized: "fajr_at \(tomorrowFajr)"))
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundStyle(.secondary.opacity(0.8))
                                .padding(.top, 4)
                                
                                HStack(spacing: 4) {
                                    if let tomorrowSunrise = tomorrowSunriseTime {
                                        Image(systemName: "sunrise")
                                            .font(.system(size: 11))
                                        Text(String(localized: "sunrise_at \(tomorrowSunrise)"))
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                }
                                .foregroundStyle(.secondary.opacity(0.8))
                                .padding(.top, 4)
                            } else if !isAfterIsha, let sunrise = prayerTimeManager.todaysTimes?.sunrise {
                                // Vor Fajr (morgens): Sunrise-Zeit anzeigen
                                HStack(spacing: 4) {
                                    Image(systemName: "sun.horizon.fill")
                                        .font(.system(size: 11))
                                    Text(String(localized: "sunrise_at \(sunrise)"))
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundStyle(.secondary.opacity(0.8))
                                .padding(.top, 4)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(
                    ZStack {
                        if colorScheme == .dark {
                            Color(.secondarySystemBackground)
                        } else {
                            LinearGradient(
                                colors: [
                                    Color.islamicGreen.opacity(0.04),
                                    Color.islamicGreen.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .cornerRadius(20)
                .shadow(color: .islamicGreen.opacity(0.1), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.islamicGreen.opacity(0.3),
                                    Color.islamicGreen.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
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
        case "sunrise": return "sunrise"
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
