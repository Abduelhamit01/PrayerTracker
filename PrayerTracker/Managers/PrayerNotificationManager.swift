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

    /// Plant Benachrichtigungen für alle Gebetszeiten
    func scheduleNotifications(for times: PrayerTimes, cityName: String) async {
        // Erst alle alten Benachrichtigungen löschen
        await cancelAllNotifications()

        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }

        let prayers: [(id: String, name: String, time: String)] = [
            ("fajr", String(localized: "fajr"), times.fajr),
            ("dhuhr", String(localized: "dhuhr"), times.dhuhr),
            ("asr", String(localized: "asr"), times.asr),
            ("maghrib", String(localized: "maghrib"), times.maghrib),
            ("isha", String(localized: "isha"), times.isha)
        ]

        for prayer in prayers {
            await scheduleNotification(
                id: prayer.id,
                prayerName: prayer.name,
                time: prayer.time,
                cityName: cityName
            )
        }
    }

    /// Plant eine einzelne Benachrichtigung
    private func scheduleNotification(id: String, prayerName: String, time: String, cityName: String) async {
        guard let (hour, minute) = parseTime(time) else {
            print("Could not parse time: \(time)")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "prayer_time_notification_title")
        content.body = String(localized: "\(prayerName)", comment: "Prayer notification body")
        content.sound = .default
        content.categoryIdentifier = "PRAYER_TIME"

        // Trigger für heute zur angegebenen Uhrzeit
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "prayer_\(id)",
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
