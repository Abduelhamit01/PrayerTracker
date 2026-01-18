//
//  PrayerCard.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 07.01.26.
//

import SwiftUI

struct PrayerCard: View {
    let prayer: Prayer
    @ObservedObject var manager: PrayerManager
    let onPartTap: (String) -> Void

    @State private var isExpanded = false
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Computed Properties

    private var isAllCompleted: Bool {
        manager.isAllCompleted(prayer: prayer)
    }

    private var completedCount: Int {
        prayer.parts.filter { manager.isPartCompleted(prayerId: prayer.id, part: $0) }.count
    }

    private var cardBackground: Color {
        colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerButton

            if isExpanded {
                expandedContent
            }
        }
        .background(cardBackground)
        .cornerRadius(14)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Header

    private var headerButton: some View {
        HStack(spacing: 14) {
            iconBox
            titleAndProgress
            Spacer()
            statusAndChevron
        }
        .padding(14)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
    }

    private var iconBox: some View {
        Image(systemName: prayer.icon)
            .font(.system(size: 22))
            .foregroundStyle(.islamicGreen)
            .frame(width: 46, height: 46)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
    }

    private var titleAndProgress: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(prayer.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("parts_completed \(completedCount) \(prayer.parts.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var statusAndChevron: some View {
        HStack(spacing: 10) {
            if isAllCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.islamicGreen)
            }

            Image(systemName: "chevron.down")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.leading, 74)

            ForEach(prayer.parts, id: \.self) { part in
                PrayerPartRow(
                    part: part,
                    isCompleted: manager.isPartCompleted(prayerId: prayer.id, part: part),
                    onTap: { onPartTap(part) }
                )

                if part != prayer.parts.last {
                    Divider()
                        .padding(.leading, 74)
                }
            }
        }
    }
}

#Preview {
    VStack {
        PrayerCard(
            prayer: Prayer(id: "fajr", name: "Fajr", parts: ["Sunnah", "Fardh"], icon: "sunrise.fill"),
            manager: PrayerManager(),
            onPartTap: { _ in }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
