//
//  PrayerManager.swift
//  TodoApp
//
//  Created by Abdülhamit Oral
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class PrayerManager: ObservableObject {
    @Published var selectedDate: Date = Date() {
        didSet {
            objectWillChange.send()
        }
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    private let storageKey = "completedParts"
    private var completedPartsData: Data {
        get {
            UserDefaults.standard.data(forKey: storageKey) ?? Data()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: storageKey)
        }
    }
    
    // Die Liste aller Gebete (islamisch korrekte Reihenfolge)
    let prayers: [Prayer] = [
        Prayer(id: "fajr", name: "Fajr", parts: ["Sunnah", "Fardh"], emoji: "🌅"),
        Prayer(id: "dhuhr", name: "Dhuhr", parts: ["Sunnah (vor)", "Fardh", "Sunnah (nach)"], emoji: "☀️"),
        Prayer(id: "asr", name: "Asr", parts: ["Sunnah", "Fardh"], emoji: "⛅️"),
        Prayer(id: "maghrib", name: "Maghrib", parts: ["Fardh", "Sunnah"], emoji: "🌆"),
        Prayer(id: "isha", name: "Isha", parts: ["Sunnah (vor)", "Fardh", "Sunnah (nach)", "Witr"], emoji: "🌙")
    ]
    
    // Getter für die erledigten Teile
    private var completedParts: Set<String> {
        guard let decoded = try? JSONDecoder().decode(Set<String>.self, from: completedPartsData) else {
            return []
        }
        return decoded
    }
    
    private func formatDateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = ("dd-MM-yyyy")
        return formatter.string(from: date)
    }
    
    func completeAllPrayers() {
        for prayer in prayers {
            setAllParts(of: prayer, to: true)
        }
    }
    
    // Prüft, ob ein bestimmtes Teil eines Gebets erledigt ist
    func isPartCompleted(prayerId: String, part: String) -> Bool {
        let datePrefix = formatDateKey(selectedDate)
        let key = "\(datePrefix)-\(prayerId)-\(part)"
        return completedParts.contains(key)
    }
    
    // Prüft, ob alle Teile eines Gebets erledigt sind
    func isAllCompleted(prayer: Prayer) -> Bool {
        prayer.parts.allSatisfy { part in
            isPartCompleted(prayerId: prayer.id, part: part)
        }
    }
    
    // Schaltet den Status eines einzelnen Teils um
    func togglePartCompletion(prayerId: String, part: String) {
        let datePrefix = formatDateKey(selectedDate)
        let key = "\(datePrefix)-\(prayerId)-\(part)"
        if completedParts.contains(key) {
            removeKey(key)
        } else {
            addKey(key)
        }
    }
    
    // Setzt alle Teile eines Gebets auf einen bestimmten Status
    func setAllParts(of prayer: Prayer, to complete: Bool) {
        let datePrefix = formatDateKey(selectedDate)
        
        for part in prayer.parts {
            let key = "\(datePrefix)-\(prayer.id)-\(part)"
            let isCurrentlyCompleted = completedParts.contains(key)
            
            if complete && !isCurrentlyCompleted {
                addKey(key)
            } else if !complete && isCurrentlyCompleted {
                removeKey(key)
            }
        }
    }
    
    // Löscht alle erledigten Gebete des ausgewählten Tages
    func clearAllCompletions() {
        let datePrefix = formatDateKey(selectedDate)
        var parts = completedParts

        // Nur Einträge des aktuellen Tages entfernen
        parts = parts.filter { !$0.hasPrefix(datePrefix) }

        updateCompletedParts(parts)
    }
    
    // Private Hilfsfunktionen für die Datenverwaltung
    private func updateCompletedParts(_ newSet: Set<String>) {
        guard let encoded = try? JSONEncoder().encode(newSet) else { return }
        
        // SwiftUI über die Änderung informieren
        objectWillChange.send()
        
        completedPartsData = encoded
    }
    
    private func addKey(_ key: String) {
        var parts = completedParts
        parts.insert(key)
        updateCompletedParts(parts)
    }
    
    private func removeKey(_ key: String) {
        var parts = completedParts
        parts.remove(key)
        updateCompletedParts(parts)
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
