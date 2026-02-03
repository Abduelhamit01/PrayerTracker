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
    @ObservedObject var prayerTimeManager: PrayerTimeManager
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
        if isAllCompleted {
            return colorScheme == .dark 
                ? Color(.secondarySystemBackground) 
                : Color.islamicGreen.opacity(0.03)
        }
        return colorScheme == .dark 
            ? Color(.secondarySystemBackground) 
            : Color(.systemBackground)
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
        .cornerRadius(16)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isAllCompleted 
                        ? Color.islamicGreen.opacity(0.3)
                        : Color.primary.opacity(0.08),
                    lineWidth: isAllCompleted ? 1.5 : 1
                )
        )
    }

    // MARK: - Header

    private var headerButton: some View {
        HStack(spacing: 16) {
            iconBox
            titleAndProgress
            Spacer()
            statusAndChevron
        }
        .padding(16)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                isExpanded.toggle()
            }
        }
    }

    private var iconBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isAllCompleted 
                        ? Color.islamicGreen.opacity(0.15)
                        : Color(.systemGray6)
                )
            
            Image(systemName: prayer.icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(
                    isAllCompleted 
                        ? Color.islamicGreen 
                        : .primary
                )
        }
        .frame(width: 52, height: 52)
    }

    private var titleAndProgress: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey(prayer.id))
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundColor(.primary)

            HStack(spacing: 6) {
                if let time = prayerTime {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text(time)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary.opacity(0.5))
                }
                
                Text("parts_completed \(completedCount) \(prayer.parts.count)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var prayerTime: String? {
        prayerTimeManager.time(for: prayer.id)
    }

    private var statusAndChevron: some View {
        HStack(spacing: 12) {
            if isAllCompleted {
                ZStack {
                    Circle()
                        .fill(Color.islamicGreen.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.islamicGreen)
                }
            }

            Image(systemName: "chevron.down")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isExpanded)
        }
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.leading, 84)

            ForEach(prayer.parts, id: \.self) { part in
                PrayerPartRow(
                    part: part,
                    isCompleted: manager.isPartCompleted(prayerId: prayer.id, part: part),
                    onTap: { onPartTap(part) }
                )

                if part != prayer.parts.last {
                    Divider()
                        .padding(.leading, 84)
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
            prayerTimeManager: PrayerTimeManager(),
            onPartTap: { _ in }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
