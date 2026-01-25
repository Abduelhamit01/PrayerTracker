//
//  ContentView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 24.11.25.
//

import SwiftUI
import ConfettiSwiftUI
import AVFoundation
import UserNotifications


struct ContentView: View {
    @StateObject private var manager = PrayerManager()
    @StateObject private var ramadanManager = RamadanManager()
    @State private var trigger: Int = 0
    @State private var selectedTab: Int = 0
    @State private var showSettings: Bool = false
    @AppStorage("ramadanModeEnabled") private var ramadanMode: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            homeTab
                .tag(0)
            historyTab
                .tag(1)
            if ramadanMode {
                ramadanTab
                .tag(2)
            }
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
            .fullScreenCover(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView()
                        .navigationTitle("Settings")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    showSettings = false
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.primary)
                                        .padding(8)
                                        .background(.thinMaterial)
                                        .clipShape(Circle())
                                }
                            }
                        }
                }
            }
        }
        .tabItem {
            Label("Home", systemImage: "house")
        }
    }

    // MARK: - Ramadan Tab

    private var ramadanTab: some View {
        RamadanView(manager: manager, ramadanManager: ramadanManager, selectedTab: $selectedTab)
            .tabItem {
                Label("Ramadan", systemImage: "moon.stars.fill")
            }
    }

    // MARK: - History Tab

    private var historyTab: some View {
        CalendarHistory(manager: manager)
            .tabItem {
                Label("History", systemImage: "calendar")
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
        
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
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
