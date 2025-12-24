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
    
    // Hilfseigenschaften für den Kalender
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = Locale(identifier: "de_DE")
        return cal
    }
    
    private var daysOfWeek: [Date] {
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        // Erzeuge die 7 Tage der aktuellen Woche
        return (0..<7).compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(daysOfWeek, id: \.self) { date in
                DayButton(
                    date: date,
                    isSelected: calendar.isDate(date, inSameDayAs: manager.selectedDate),
                    onTap: {
                        withAnimation {
                            manager.selectedDate = date
                        }
                    },
                    namespace: selectionNS
                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
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
    
    @State var offset: CGSize = .zero
    var body: some View {

        VStack(spacing: 8) {
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
        .offset(offset)
        .gesture(
            DragGesture()
            .onChanged { value in
                withAnimation(.spring()) {
                    offset = value.translation
                }
            }
                .onEnded { value in
                    withAnimation(.spring()) {
                        offset = .zero
                    }
                }
        )
    }
}

#Preview {
    WeekView(manager: PrayerManager())
}

