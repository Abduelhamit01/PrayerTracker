import SwiftUI

struct RamadanTimelineView: View {
    // Parameter, die von außen kommen
    let currentDay: Int
    let completedDays: Set<String>
    let totalDays: Int
    let ramadanStart: Date
    let monthlyTimes: [PrayerTimes]

    // Callback wenn ein Tag angetippt wird
    var onDayTapped: ((Date) -> Void)?
    // Welcher Tag gerade ausgewählt ist (für visuelles Feedback)
    var selectedDate: Date?

    // Environment für ColorScheme (Hell/Dunkel Modus)
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ramadanManager: RamadanManager

    private let gregorianFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Puffer am Anfang, damit Tag 1 nicht am Rand klebt
                    Spacer().frame(width: 10)

                    ForEach(1...totalDays, id: \.self) { day in
                        let dayDate = getDate(for: day)
                        let dayState = getDayState(day: day)
                        let times = getPrayerTimes(for: dayDate)

                        TimelineDayItem(
                            dayNumber: day,
                            date: dayDate,
                            state: dayState,
                            moonIcon: getMoonPhaseIcon(for: day),
                            isSelected: isSelected(dayDate),
                            fajrTime: times?.fajr,
                            iftarTime: times?.maghrib
                        )
                        .id(day)
                        .onTapGesture {
                            if dayState == .missed {
                                onDayTapped?(dayDate)
                            }
                        }
                    }

                    // Puffer am Ende
                    Spacer().frame(width: 10)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring()) {
                        let scrollTarget = currentDay < 1 ? 1 : currentDay
                        proxy.scrollTo(scrollTarget, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 150) // Feste Höhe für die Timeline (inkl. Fajr/Iftar)
    }
    
    // MARK: - Logik Helper
    
    // Berechnet das Gregorianische Datum basierend auf dem Ramadan-Start
    private func getDate(for day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day - 1, to: ramadanStart) ?? Date()
    }
    
    // Bestimmt den Status des Tages anhand der echten Check-in-Daten
    private func getDayState(day: Int) -> DayState {
        let date = getDate(for: day)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)

        if completedDays.contains(key) { return .completed }
        if day == currentDay { return .current }

        // Vergangene Tage, die nicht abgehakt wurden
        let today = Calendar.current.startOfDay(for: Date())
        let dayDate = Calendar.current.startOfDay(for: date)
        if dayDate < today && dayDate >= Calendar.current.startOfDay(for: ramadanStart) {
            return .missed
        }

        return .future
    }

    // Prüft ob ein Datum dem ausgewählten Datum entspricht
    private func isSelected(_ date: Date) -> Bool {
        guard let selected = selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selected)
    }

    // Sucht Gebetszeiten für ein Datum aus den gecachten Monatsdaten
    private func getPrayerTimes(for date: Date) -> PrayerTimes? {
        let key = gregorianFormatter.string(from: date)
        return monthlyTimes.first { $0.gregorianDateShort == key }
    }
    
    // 🌙 PRÄZISE MONDPHASEN-LOGIK 🌙
    // Basiert auf einem 30-Tage Mondzyklus
    private func getMoonPhaseIcon(for day: Int) -> String {
        switch day {
        case 1...2:   return "moonphase.waxing.crescent"      // Neulicht/Sichel
        case 3...6:   return "moonphase.waxing.crescent"      // Dickere Sichel
        case 7...9:   return "moonphase.first.quarter"        // Halbmond (Zunehmend)
        case 10...12: return "moonphase.waxing.gibbous"       // Dreiviertelmond
        case 13...16: return "moonphase.full.moon"            // VOLLMOND (Die weißen Tage)
        case 17...20: return "moonphase.waning.gibbous"       // Abnehmend
        case 21...23: return "moonphase.last.quarter"         // Halbmond (Abnehmend)
        case 24...28: return "moonphase.waning.crescent"      // Sichel (Morgens sichtbar)
        case 29...30: return "moonphase.new.moon"             // Neumond / Nicht sichtbar
        default:      return "moon"
        }
    }
}

// MARK: - Subviews & Models

enum DayState {
    case completed, current, missed, future
}

struct TimelineDayItem: View {
    let dayNumber: Int
    let date: Date
    let state: DayState
    let moonIcon: String
    var isSelected: Bool = false
    var fajrTime: String?
    var iftarTime: String?

    // Farben definieren
    private var activeColor: Color { Color("IslamicGreen") }
    private var missedColor: Color { Color.orange }
    private var moonColor: Color { Color(red: 1.0, green: 0.85, blue: 0.4) }

    var body: some View {
        VStack(spacing: 4) {
            // 1. Fajr-Zeit oben (Sahur-Ende)
            if let fajr = fajrTime {
                Text(fajr)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.8))
            } else {
                Text(" ")
                    .font(.system(size: 9))
            }

            // 2. Label (Tag X)
            Text("Tag \(dayNumber)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(labelColor)
                .opacity(state == .future ? 0.6 : 1.0)

            // 3. Der Bubble / Kreis
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 56, height: 56)
                    .shadow(color: state == .current ? activeColor.opacity(0.4) : .clear, radius: 8, y: 4)
                    .overlay(
                        Circle()
                            .stroke(ringColor, lineWidth: 2)
                            .scaleEffect(1.1)
                            .opacity(showRing ? 1 : 0)
                    )
                iconView
            }
            .scaleEffect(state == .current || isSelected ? 0.8 : 0.9)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: state)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)

            // 4. Datum unten (z.B. 18. Feb)
            Text(dateFormatter.string(from: date))
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)

            // 5. Iftar-Zeit unten (Fastenbrechen)
            if let iftar = iftarTime {
                Text(iftar)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(activeColor.opacity(0.8))
            } else {
                Text(" ")
                    .font(.system(size: 9))
            }
        }
    }

    // Computed Properties für sauberen Body

    private var labelColor: Color {
        switch state {
        case .current: return activeColor
        case .missed: return missedColor
        default: return .secondary
        }
    }

    private var showRing: Bool {
        state == .current || isSelected
    }

    private var ringColor: Color {
        if isSelected && state == .missed { return missedColor }
        if state == .current { return activeColor }
        return .clear
    }

    private var backgroundColor: Color {
        switch state {
        case .completed: return activeColor.opacity(0.15)
        case .current:   return activeColor
        case .missed:    return missedColor.opacity(0.15)
        case .future:    return Color.gray.opacity(0.1)
        }
    }

    @ViewBuilder
    private var iconView: some View {
        switch state {
        case .completed:
            Image(systemName: "checkmark")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(activeColor)
                .transition(.scale.combined(with: .opacity))

        case .current:
            Image(systemName: moonIcon)
                .font(.system(size: 24))
                .foregroundStyle(.white)

        case .missed:
            Image(systemName: "exclamationmark")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(missedColor)

        case .future:
            Image(systemName: moonIcon)
                .font(.system(size: 20))
                .foregroundColor(.gray.opacity(0.4))
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMM" // z.B. "18. Feb"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
}

#Preview("TimelineDayItem States") {
    VStack(spacing: 16) {
        TimelineDayItem(
            dayNumber: 10,
            date: Date(),
            state: .current,
            moonIcon: "moonphase.full.moon",
            isSelected: true,
            fajrTime: "05:15",
            iftarTime: "17:45"
        )
        TimelineDayItem(
            dayNumber: 9,
            date: Date(),
            state: .completed,
            moonIcon: "moonphase.waxing.gibbous",
            fajrTime: "05:16",
            iftarTime: "17:44"
        )
        TimelineDayItem(
            dayNumber: 8,
            date: Date(),
            state: .missed,
            moonIcon: "moonphase.first.quarter",
            fajrTime: "05:18",
            iftarTime: "17:42"
        )
        TimelineDayItem(
            dayNumber: 11,
            date: Date(),
            state: .future,
            moonIcon: "moonphase.waning.crescent"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
