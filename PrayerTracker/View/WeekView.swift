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
    
    @State private var position = ScrollPosition(id: "current")
    @State private var monatsString: String = "Dezember 2025"
    
    // Hilfseigenschaften für den Kalender
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = Locale(identifier: "de_DE")
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
        formatter.locale = Locale(identifier: "de_DE")

        let dates = getWeek(zahl: weekOffset)
        
        if dates.count >= 4 {
            let donnerstag = dates[3]
            monatsString = formatter.string(from: donnerstag)
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(monatsString)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(-52...52, id: \.self) { weekOffset in
                        HStack(spacing: 10) {
                            ForEach(getWeek(zahl: weekOffset), id: \.self) { date in
                                DayButton(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: manager.selectedDate),
                                    onTap: {
                                        withAnimation {
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
            .padding(.bottom, 10)
            .onAppear {
                position.scrollTo(id: 0)
                updateMonthDisplay(for: 0)
            }

            .onScrollTargetVisibilityChange(idType: Int.self) { ids in
                if let sichtbareWoche = ids.first {
                    updateMonthDisplay(for: sichtbareWoche)
                }
            }
      }

    
struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void
    let namespace: Namespace.ID
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
    
    private var numberFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    var body: some View {
        
        VStack() {
            Text(dayFormatter.string(from: date).uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(isSelected ? .white : .secondary)
            
            Text(numberFormatter.string(from: date))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color(red: 0/255, green: 144/255, blue: 0/255))
                    .matchedGeometryEffect(id: "selectedDay", in: namespace)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
            }
        }
        .onTapGesture(perform: onTap)
        }
    }
}

#Preview {
    WeekView(manager: PrayerManager())
}

