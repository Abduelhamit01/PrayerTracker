import SwiftUI

struct CalendarHistory: View {
    @ObservedObject var manager: PrayerManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Kalender Card
                    VStack(spacing: 0) {
                        CustomCalendarView(manager: manager)
                            .padding(.vertical)
                    }
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Statistik Card
                    StatisticsCard(manager: manager)
                        .padding(.horizontal)

                }
                .padding(.top)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Gebetsverlauf")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Statistics Card

struct StatisticsCard: View {
    @ObservedObject var manager: PrayerManager

    private var stats: (complete: Int, partial: Int, missed: Int) {
        calculateStats()
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Statistik")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("Letzte 30 Tage")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                StatItem(
                    value: stats.complete,
                    label: "Vollständig",
                    color: .green,
                    icon: "checkmark.circle.fill"
                )

                StatItem(
                    value: stats.partial,
                    label: "Teilweise",
                    color: .yellow,
                    icon: "circle.lefthalf.filled"
                )

                StatItem(
                    value: stats.missed,
                    label: "Verpasst",
                    color: .red,
                    icon: "xmark.circle.fill"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func calculateStats() -> (complete: Int, partial: Int, missed: Int) {
        let calendar = Calendar.current
        let today = Date()

        var complete = 0
        var partial = 0
        var missed = 0

        for dayOffset in 0..<30 {  // Inkl. heute
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            let status = getDayStatus(for: date)
            switch status {
            case .complete: complete += 1
            case .partial: partial += 1
            case .missed: missed += 1
            case .none: break  // Tage ohne Relevanz überspringen
            }
        }

        return (complete, partial, missed)
    }

    private enum DayStatus {
        case complete, partial, missed, none
    }

    private func getDayStatus(for date: Date) -> DayStatus {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateKey = formatter.string(from: date)
        let installDate = AppInstallDate.shared.installDate
        let isBeforeInstall = date < calendar.startOfDay(for: installDate)

        var fardhCompleted = 0
        var sunnahCompleted = 0
        var totalFardh = 0

        guard let data = UserDefaults.standard.data(forKey: "completedParts"),
              let completedParts = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            // Keine Daten vorhanden
            return isBeforeInstall ? .none : .missed
        }

        for prayer in manager.prayers {
            for part in prayer.parts {
                let key = "\(dateKey)-\(prayer.id)-\(part)"
                let isCompleted = completedParts.contains(key)

                if part == "Fardh" {
                    totalFardh += 1
                    if isCompleted { fardhCompleted += 1 }
                } else {
                    if isCompleted { sunnahCompleted += 1 }
                }
            }
        }

        // Tage vor Installation ohne Einträge: nicht zählen
        if isBeforeInstall && fardhCompleted == 0 && sunnahCompleted == 0 {
            return .none
        }

        if fardhCompleted == 0 { return .missed }
        if fardhCompleted == totalFardh { return .complete }
        return .partial
    }
}

struct StatItem: View {
    let value: Int
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct LegendRow: View {
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
    }
}

#Preview {
    CalendarHistory(manager: PrayerManager())
}
