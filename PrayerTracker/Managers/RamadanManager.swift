//
//  RamadanManager.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 24.01.26.
//

import Foundation
import SwiftUI
import Combine

class RamadanManager: ObservableObject {
    @Published var completedDays: Set<String>

    private let storageKey = "ramadanCompletedDays"
    private var cancellables = Set<AnyCancellable>()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // Ramadan 2026: 19. Februar - 19. März (29 Tage)
    let ramadanStart: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 19
        return Calendar.current.date(from: components)!
    }()

    let ramadanEnd: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 19
        return Calendar.current.date(from: components)!
    }()

    let totalDays: Int = 29

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.completedDays = decoded
        } else {
            self.completedDays = []
        }

        NotificationCenter.default.publisher(for: .didClearAllData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.clearAllData()
            }
            .store(in: &cancellables)
    }

    private func save() {
        guard let encoded = try? JSONEncoder().encode(completedDays) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    private func dateKey(for date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    func notOnlyToday(for date: Date) {
        completedDays.insert(dateKey(for: date))
        save()
        objectWillChange.send()
    }

    var todayKey: String {
        dateKey(for: Date())
    }

    var todayCompleted: Bool {
        completedDays.contains(todayKey)
    }

    var currentDay: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: ramadanStart)

        guard today >= start else { return 0 }

        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return min(days + 1, totalDays)
    }

    var isRamadanActive: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: ramadanStart)
        let end = Calendar.current.startOfDay(for: ramadanEnd)
        return today >= start && today <= end
    }

    func refresh() {
        objectWillChange.send()
    }

    func completeToday() {
        completedDays.insert(todayKey)
        save()
        objectWillChange.send()
    }

    func uncompleteToday() {
        completedDays.remove(todayKey)
        save()
        objectWillChange.send()
    }

    private func clearAllData() {
        completedDays = []
        save()
        objectWillChange.send()
    }
}
