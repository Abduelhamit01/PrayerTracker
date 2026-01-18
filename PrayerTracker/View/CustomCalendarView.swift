//
//  CustomCalendarView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 04.01.26.
//

import SwiftUI

struct CustomCalendarView: View {
    @ObservedObject var manager: PrayerManager
    @State private var currentMonthIndex: Int = 0

    let calendar = Calendar.current
    private var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        // Sonntag ist Index 0, also array beginnt mit Sonntag
        let symbols = formatter.veryShortWeekdaySymbols ?? ["S", "M", "T", "W", "T", "F", "S"]
        return symbols
    }
    private let gridHeight: CGFloat = 340

    // Bereich: 24 Monate zurück bis 24 Monate voraus
    private let monthRange = -24...24

    var body: some View {
        VStack(spacing: 12) {
            // Month Navigation
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.islamicGreen)
                }

                Spacer()

                Text(monthYearString(for: currentMonthIndex))
                    .font(.title2)
                    .bold()

                Spacer()

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.islamicGreen)
                }
            }
            .padding(.horizontal)

            // Days of Week Header
            HStack {
                ForEach(0..<daysOfWeek.count, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            // Swipeable Month Pages
            TabView(selection: $currentMonthIndex) {
                ForEach(monthRange, id: \.self) { offset in
                    MonthGridView(
                        monthDate: getMonthDate(for: offset),
                        manager: manager,
                        calendar: calendar,
                        gridHeight: gridHeight
                    )
                    .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: gridHeight)
        }
    }

    // MARK: - Helper Functions

    private func getMonthDate(for offset: Int) -> Date {
        calendar.date(byAdding: .month, value: offset, to: Date()) ?? Date()
    }

    private func monthYearString(for offset: Int) -> String {
        let date = getMonthDate(for: offset)
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func changeMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newIndex = currentMonthIndex + value
            if monthRange.contains(newIndex) {
                currentMonthIndex = newIndex
            }
        }
    }
}

// MARK: - Month Grid View

struct MonthGridView: View {
    let monthDate: Date
    @ObservedObject var manager: PrayerManager
    let calendar: Calendar
    let gridHeight: CGFloat

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        let days = getDaysInMonth(for: monthDate)

        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days.indices, id: \.self) { index in
                let day = days[index]
                if day == 0 {
                    Color.clear
                        .frame(width: 40, height: 50)
                } else {
                    let fullDate = getFullDate(day: day, from: monthDate)
                    let isSelected = calendar.isDate(fullDate, inSameDayAs: manager.selectedDate)
                    let isToday = calendar.isDateInToday(fullDate)

                    DayCell(
                        day: day,
                        isSelected: isSelected,
                        isToday: isToday,
                        statusColor: getStatusColor(for: fullDate)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            manager.selectedDate = fullDate
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Day Cell

    struct DayCell: View {
        let day: Int
        let isSelected: Bool
        let isToday: Bool
        let statusColor: Color

        var body: some View {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.islamicGreen : (isToday ? .islamicGreen.opacity(0.2) : Color.clear))
                    )
                    .foregroundColor(isSelected ? .white : (isToday ? .islamicGreen : .primary))

                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
                    .opacity(statusColor == .clear ? 0 : 1)
            }
            .frame(width: 40, height: 50)
        }
    }

    // MARK: - Status Berechnung

    private var installDate: Date {
        AppInstallDate.shared.installDate
    }

    private func getStatusColor(for date: Date) -> Color {
        // Zukünftige Tage: kein Punkt
        if date > Date() && !calendar.isDateInToday(date) {
            return .clear
        }

        let dateKey = formatDateKey(date)
        let isBeforeInstall = date < calendar.startOfDay(for: installDate)

        var fardhCompleted = 0
        var sunnahCompleted = 0
        var totalFardh = 0

        for prayer in manager.prayers {
            for part in prayer.parts {
                let key = "\(dateKey)-\(prayer.id)-\(part)"
                let isCompleted = isPartCompleted(key: key)

                if part == "Fardh" {
                    totalFardh += 1
                    if isCompleted { fardhCompleted += 1 }
                } else {
                    if isCompleted { sunnahCompleted += 1 }
                }
            }
        }

        // Tage vor Installation ohne Einträge: kein Punkt
        if isBeforeInstall && fardhCompleted == 0 && sunnahCompleted == 0 {
            return .clear
        }

        // Kein Fardh gebetet -> Rot
        if fardhCompleted == 0 {
            return .red
        }

        // Alle Fardh erledigt -> Grün
        if fardhCompleted == totalFardh {
            return .green
        }

        // Einige Fardh verpasst -> Gelb
        return .yellow
    }

    private func isPartCompleted(key: String) -> Bool {
        let storageKey = "completedParts"
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return false
        }
        return decoded.contains(key)
    }

    private func formatDateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }

    // MARK: - Helper Functions

    private func getDaysInMonth(for date: Date) -> [Int] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let numDays = range.count
        let leadingEmptyDays = firstWeekday - 1

        var days: [Int] = Array(repeating: 0, count: leadingEmptyDays)
        days += Array(1...numDays)

        while days.count < 42 {
            days.append(0)
        }

        return days
    }

    private func getFullDate(day: Int, from date: Date) -> Date {
        var components = calendar.dateComponents([.year, .month], from: date)
        components.day = day
        return calendar.date(from: components) ?? date
    }
}

#Preview {
    CustomCalendarView(manager: PrayerManager())
}
