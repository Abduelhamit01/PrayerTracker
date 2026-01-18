//
//  PrayerManager.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

// Notification für das Löschen aller Daten
extension Notification.Name {
    static let didClearAllData = Notification.Name("didClearAllData")
}

class PrayerManager: ObservableObject {
    @Published var selectedDate: Date = Date()

    private let storageKey = "completedParts"
    private var cancellables = Set<AnyCancellable>()

    // Gecachte Daten - wird nur einmal beim Start geladen
    private var completedParts: Set<String> {
        didSet {
            saveToStorage()
        }
    }

    // DateFormatter cachen (teuer zu erstellen)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()

    // Die Liste aller Gebete (islamisch korrekte Reihenfolge)
    let prayers: [Prayer] = [
        Prayer(id: "fajr", name: "Fajr", parts: ["Sunnah", "Fardh"], icon: "sunrise.fill"),
        Prayer(id: "dhuhr", name: "Dhuhr", parts: ["Sunnah (vor)", "Fardh", "Sunnah (nach)"], icon: "sun.max.fill"),
        Prayer(id: "asr", name: "Asr", parts: ["Sunnah", "Fardh"], icon: "sun.min.fill"),
        Prayer(id: "maghrib", name: "Maghrib", parts: ["Fardh", "Sunnah"], icon: "sunset.fill"),
        Prayer(id: "isha", name: "Isha", parts: ["Sunnah (vor)", "Fardh", "Sunnah (nach)", "Witr"], icon: "moon.fill")
    ]

    init() {
        // Einmal beim Start laden
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.completedParts = decoded
        } else {
            self.completedParts = []
        }

        // Auf Datenlöschung reagieren
        NotificationCenter.default.publisher(for: .didClearAllData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.clearCache()
            }
            .store(in: &cancellables)
    }

    /// Leert den internen Cache (wird nach Datenlöschung aufgerufen)
    private func clearCache() {
        completedParts = []
        objectWillChange.send()
    }

    private func saveToStorage() {
        guard let encoded = try? JSONEncoder().encode(completedParts) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    private func formatDateKey(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    func completeAllPrayers() {
        let datePrefix = formatDateKey(selectedDate)
        var newParts = completedParts

        for prayer in prayers {
            for part in prayer.parts {
                newParts.insert("\(datePrefix)-\(prayer.id)-\(part)")
            }
        }

        completedParts = newParts
        objectWillChange.send()
    }

    // Prüft, ob ein bestimmtes Teil eines Gebets erledigt ist
    func isPartCompleted(prayerId: String, part: String) -> Bool {
        let key = "\(formatDateKey(selectedDate))-\(prayerId)-\(part)"
        return completedParts.contains(key)
    }

    // Prüft, ob alle Teile eines Gebets erledigt sind
    func isAllCompleted(prayer: Prayer) -> Bool {
        let datePrefix = formatDateKey(selectedDate)
        return prayer.parts.allSatisfy { part in
            completedParts.contains("\(datePrefix)-\(prayer.id)-\(part)")
        }
    }

    // Schaltet den Status eines einzelnen Teils um
    func togglePartCompletion(prayerId: String, part: String) {
        let key = "\(formatDateKey(selectedDate))-\(prayerId)-\(part)"

        if completedParts.contains(key) {
            completedParts.remove(key)
        } else {
            completedParts.insert(key)
        }
        objectWillChange.send()
    }

    // Setzt alle Teile eines Gebets auf einen bestimmten Status
    func setAllParts(of prayer: Prayer, to complete: Bool) {
        let datePrefix = formatDateKey(selectedDate)

        for part in prayer.parts {
            let key = "\(datePrefix)-\(prayer.id)-\(part)"
            if complete {
                completedParts.insert(key)
            } else {
                completedParts.remove(key)
            }
        }
        objectWillChange.send()
    }

    // Löscht alle erledigten Gebete des ausgewählten Tages
    func clearAllCompletions() {
        let datePrefix = formatDateKey(selectedDate)
        completedParts = completedParts.filter { !$0.hasPrefix(datePrefix) }
        objectWillChange.send()
    }
    
    func goToNextWeek() {
        let cal = Calendar.current
        if let newDate = cal.date(byAdding: .weekOfYear, value: 1, to: selectedDate){
            selectedDate = newDate
        }
    }

    func goToPreviousWeek() {
        let cal = Calendar.current
        if let newDate = cal.date(byAdding: .weekOfYear, value: -1, to: selectedDate){
            selectedDate = newDate
        }
    }
    
    func playSuccessSound() {
        AudioServicesPlaySystemSound(1407)
    }
}
