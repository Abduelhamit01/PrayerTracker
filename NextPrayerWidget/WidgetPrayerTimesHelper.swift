//
//  WidgetPrayerTimesHelper.swift
//  NextPrayerWidgetExtension
//
//  Created by Abdülhamit Oral on 10.02.26.
//

import Foundation

/// Shared Helper für alle Widgets: Liest das Monats-Array aus der App Group
/// und schlägt Zeiten für beliebige Tage nach.
enum WidgetPrayerTimesHelper {
    private static let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()

    /// Lädt alle monatlichen Gebetszeiten aus der App Group
    static func loadMonthlyTimes() -> [PrayerTimes] {
        guard let data = shared?.data(forKey: "widgetMonthlyPrayerTimes"),
              let times = try? JSONDecoder().decode([PrayerTimes].self, from: data) else {
            return []
        }
        return times
    }

    /// Sucht Gebetszeiten für ein bestimmtes Datum
    static func times(for date: Date) -> PrayerTimes? {
        let dateString = dateFormatter.string(from: date)
        return loadMonthlyTimes().first { $0.gregorianDateShort == dateString }
    }

    /// Gibt den Stadtnamen zurück
    static var cityName: String {
        shared?.string(forKey: "widgetCityName") ?? "-"
    }

    /// Erstellt ein Date aus einem Zeitstring (z.B. "06:19") für einen bestimmten Tag
    static func dateFromTimeString(_ time: String, on day: Date) -> Date? {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: day)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        return calendar.date(from: dateComponents)
    }
}
