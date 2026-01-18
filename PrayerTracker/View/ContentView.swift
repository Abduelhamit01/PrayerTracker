//
//  ContentView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 24.11.25.
//

import SwiftUI
import ConfettiSwiftUI
import AVFoundation


struct ContentView: View {
    @StateObject private var manager = PrayerManager()
    @State private var trigger: Int = 0

    var body: some View {
        TabView {
            homeTab
            historyTab
            settingsTab
        }
        .navigationBarBackButtonHidden(true)
        .confettiCannon(
            trigger: $trigger,
            confettis: ConfettiConfiguration.prayerEmojis,
            confettiSize: ConfettiConfiguration.confettiSize,
            rainHeight: ConfettiConfiguration.rainHeight,
            radius: ConfettiConfiguration.radius,
            repetitionInterval: ConfettiConfiguration.repetitionInterval
        )
    }

    // MARK: - Home Tab

    private var homeTab: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    WeekView(manager: manager)
                        .padding(.top)

                    ForEach(manager.prayers) { prayer in
                        PrayerCard(
                            prayer: prayer,
                            manager: manager,
                            onPartTap: { part in handlePartTap(prayer: prayer, part: part) }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Prayer Tracker")
            .toolbar { homeToolbar }
        }
        .tabItem {
            Label("Home", systemImage: "house")
        }
    }

    // MARK: - History Tab

    private var historyTab: some View {
        CalendarHistory(manager: manager)
            .tabItem {
                Label("History", systemImage: "calendar")
            }
    }

    // MARK: - Settings Tab

    private var settingsTab: some View {
        SettingsView()
        .tabItem {
            Label("Setting", systemImage: "gear")
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var homeToolbar: some ToolbarContent {
        if !Calendar.current.isDateInToday(manager.selectedDate) {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("today") {
                    withAnimation(.snappy) {
                        manager.selectedDate = Date()
                    }
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Menu("", systemImage: "ellipsis.circle") {
                Button {
                    manager.completeAllPrayers()
                } label: {
                    Label("Complete all Prayers", systemImage: "checkmark.circle.fill")
                }

                Button(role: .destructive) {
                    manager.clearAllCompletions()
                } label: {
                    Label("Clear all completions", systemImage: "trash")
                }
            }
        }
    }

    // MARK: - Actions

    private func handlePartTap(prayer: Prayer, part: String) {
        let wereAllCompleted = manager.isAllCompleted(prayer: prayer)
        manager.togglePartCompletion(prayerId: prayer.id, part: part)
        let areAllCompletedNow = manager.isAllCompleted(prayer: prayer)

        if !wereAllCompleted && areAllCompletedNow {
            trigger += 1
            manager.playSuccessSound()
        }
    }
}

#Preview {
    ContentView()
}
