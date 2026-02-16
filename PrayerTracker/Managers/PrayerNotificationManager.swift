//
//  PrayerNotificationManager.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 29.01.26.
//

import Foundation
import UserNotifications
import Combine

class PrayerNotificationManager: ObservableObject {
    static let shared = PrayerNotificationManager()

    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    /// Prüft den aktuellen Berechtigungsstatus
    @MainActor
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        self.authorizationStatus = settings.authorizationStatus
        self.isAuthorized = settings.authorizationStatus == .authorized
    }

    /// Fragt nach Berechtigung für Benachrichtigungen
    @MainActor
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            self.isAuthorized = granted
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    // MARK: - Schedule Notifications

    /// Plant Benachrichtigungen für bis zu 12 Tage voraus (max 60 Notifications, iOS-Limit 64)
    func scheduleNotifications(monthlyTimes: [PrayerTimes], cityName: String) async {
        await cancelAllNotifications()

        await checkAuthorizationStatus()
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }

        let calendar = Calendar.current
        let now = Date()

        for dayOffset in 0..<12 {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            let dateString = dateFormatter.string(from: targetDate)

            guard let dayTimes = monthlyTimes.first(where: { $0.gregorianDateShort == dateString }) else { continue }

            let prayers: [(id: String, name: String, time: String)] = [
                ("fajr", String(localized: "fajr"), dayTimes.fajr),
                ("dhuhr", String(localized: "dhuhr"), dayTimes.dhuhr),
                ("asr", String(localized: "asr"), dayTimes.asr),
                ("maghrib", String(localized: "maghrib"), dayTimes.maghrib),
                ("isha", String(localized: "isha"), dayTimes.isha)
            ]

            for prayer in prayers {
                await scheduleNotification(
                    id: prayer.id,
                    prayerName: prayer.name,
                    time: prayer.time,
                    date: targetDate
                )
            }
        }
    }

    /// Plant eine einzelne Benachrichtigung mit exaktem Datum
    private func scheduleNotification(id: String, prayerName: String, time: String, date: Date) async {
        guard let (hour, minute) = parseTime(time) else {
            print("Could not parse time: \(time)")
            return
        }

        let calendar = Calendar.current
        guard let fireDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date),
              fireDate > Date() else {
            return // Vergangene Zeiten überspringen
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "prayer_time_notification_title")
        content.body = prayerName // Bereits lokalisiert
        content.sound = .default
        content.categoryIdentifier = "PRAYER_TIME"
        content.interruptionLevel = .timeSensitive

        // Volle DateComponents für exakte Zustellung (kein iOS-Batching)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let dayString = dateFormatter.string(from: date)
        let request = UNNotificationRequest(
            identifier: "prayer_\(id)_\(dayString)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Error scheduling notification for \(prayerName): \(error)")
        }
    }

    /// Löscht alle geplanten Benachrichtigungen
    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
    }

    /// Löscht Benachrichtigungen für ein bestimmtes Gebet
    func cancelNotification(for prayerId: String) {
        center.removePendingNotificationRequests(withIdentifiers: ["prayer_\(prayerId)"])
    }

    // MARK: - Helper

    /// Parst Zeit-String "HH:mm" zu (hour, minute)
    private func parseTime(_ time: String) -> (hour: Int, minute: Int)? {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }
        return (hour, minute)
    }

    /// Gibt alle geplanten Benachrichtigungen zurück (für Debugging)
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
}
