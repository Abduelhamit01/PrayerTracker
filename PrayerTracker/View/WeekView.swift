//
//  WeekView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 18.12.25.
//

import SwiftUI

struct WeekView: View {
    @ObservedObject var manager: PrayerManager
    @Namespace private var selectionNS

    @State var position = ScrollPosition(id: "current")
    @State private var monatsString: String = ""
    @State private var showHijri = false

    // Hilfseigenschaften für den Kalender
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = Locale.current
        return cal
    }

    func getWeek(zahl: Int) -> [Date] {
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let targetWeekStart = calendar.date(byAdding: .weekOfYear, value: zahl, to: startOfWeek)!

        return (0..<7).compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day, to: targetWeekStart)
        }
    }

    func weekOffsetForDate(_ date: Date) -> Int {
        let selectedStartOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let todayStartOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!

        let weeks = calendar.dateComponents([.weekOfYear], from: todayStartOfWeek, to: selectedStartOfWeek).weekOfYear ?? 0
        return weeks
    }

    func updateMonthDisplay(for weekOffset: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale.current

        let dates = getWeek(zahl: weekOffset)

        if dates.count >= 4 {
            let donnerstag = dates[3]
            monatsString = formatter.string(from: donnerstag)
        }
    }
    
    func hijriDateString() -> String {
        let hijriCalendar = Calendar(identifier: .islamic)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MMMM.yyyy"
        dateFormatter.locale = Locale(identifier: "de")
        dateFormatter.calendar = hijriCalendar
        let hijriString = dateFormatter.string(from: Date())
        
        return hijriString
    }
    

    
    var body: some View {
        VStack(spacing: 12) {
            // Month Display with Glass Effect
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(showHijri ? hijriDateString() : monatsString)
                    .onTapGesture {
                        withAnimation(.bouncy){
                            showHijri.toggle()
                        }
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.primary.opacity(0.12), lineWidth: 1)
            )
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(-52...52, id: \.self) { weekOffset in
                        HStack(spacing: 10) {
                            ForEach(getWeek(zahl: weekOffset), id: \.self) { date in
                                DayButton(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: manager.selectedDate),
                                    statusColor: getStatusColor(for: date),
                                    onTap: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                            manager.selectedDate = date
                                            let offset = weekOffsetForDate(date)
                                            position.scrollTo(id: offset)
                                            updateMonthDisplay(for: offset)
                                        }
                                    },
                                    namespace: selectionNS
                                )
                            }
                        }
                        .id(weekOffset)
                        .containerRelativeFrame(.horizontal)
                    }
                }
            }
            .scrollTargetLayout()
        }
            .scrollPosition($position)
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .onAppear {
                position.scrollTo(id: 0)
                updateMonthDisplay(for: 0)
            }

            .onScrollTargetVisibilityChange(idType: Int.self) { ids in
                if let sichtbareWoche = ids.first {
                    updateMonthDisplay(for: sichtbareWoche)
                }
            }

            .onChange(of: manager.selectedDate) { oldDate, newDate in
                let offset = weekOffsetForDate(newDate)
                position.scrollTo(id: offset)
                updateMonthDisplay(for: offset)

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

    struct DayButton: View {
        let date: Date
        let isSelected: Bool
        let statusColor: Color
        let onTap: () -> Void
        let namespace: Namespace.ID

        @Environment(\.colorScheme) var colorScheme

        private var isToday: Bool {
            Calendar.current.isDateInToday(date)
        }

        private var cardBackground: Color {
            colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)
        }

        private var dayFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "EE"
            formatter.locale = Locale.current
            return formatter
        }

        private var numberFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            return formatter
        }


        var body: some View {
            VStack(spacing: 6) {
                Text(dayFormatter.string(from: date).uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? .white : (isToday ? .islamicGreen : .secondary))
                    .tracking(0.5)

                Text(numberFormatter.string(from: date))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? .white : (isToday ? .islamicGreen : .primary))

                // Status Punkt with glow effect
                ZStack {
                    if statusColor != .clear {
                        Circle()
                            .fill(statusColor.opacity(0.2))
                            .frame(width: 10, height: 10)
                        
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(height: 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.islamicGreen,
                                    Color.islamicGreen.opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .matchedGeometryEffect(id: "selectedDay", in: namespace)
                        .shadow(color: .islamicGreen.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                else if isToday {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.islamicGreen.opacity(0.8),
                                            Color.islamicGreen.opacity(0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: .islamicGreen.opacity(0.15), radius: 6, x: 0, y: 3)
                }
                else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 4, x: 0, y: 2)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 14))
            .onTapGesture(perform: onTap)
        }
    }
}

#Preview {
    WeekView(manager: PrayerManager())
}
