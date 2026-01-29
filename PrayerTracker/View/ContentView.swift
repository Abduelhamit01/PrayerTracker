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

// MARK: - Liquid Glass Modifier

extension View {
    @ViewBuilder
    func liquidGlass() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .capsule)
        } else {
            self
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(.primary.opacity(0.15), lineWidth: 1)
                )
        }
    }
}

struct ContentView: View {
    @StateObject private var manager = PrayerManager()
    @StateObject private var ramadanManager = RamadanManager()
    @StateObject private var prayerTimeManager = PrayerTimeManager()
    @State private var trigger: Int = 0
    @State private var selectedTab: Int = 0
    @State private var showSettings: Bool = false
    @State private var showWhatsNew: Bool = false
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
        .sheet(isPresented: $showWhatsNew) {
            WhatsNewView()
        }
        .onAppear {
            if WhatsNewManager.shouldShowWhatsNew {
                showWhatsNew = true
                WhatsNewManager.markAsSeen()
            }
        }
    }


    // MARK: - Home Tab

    private var homeTab: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    WeekView(manager: manager)
                    NextPrayerCountdownView(prayerTimeManager: prayerTimeManager)

                    ForEach(manager.prayers) { prayer in
                        PrayerCard(
                            prayer: prayer,
                            manager: manager,
                            prayerTimeManager: prayerTimeManager,
                            onPartTap: { part in handlePartTap(prayer: prayer, part: part) }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .contentMargins(.top, -10, for: .scrollContent)
            .background(Color(.systemGroupedBackground))
            .toolbar { homeToolbar }
            .fullScreenCover(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView(prayerTimeManager: prayerTimeManager)
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
            .task {
                await prayerTimeManager.fetchTodaysTimes()
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

        ToolbarItem(placement: .principal) {
            Button {
                showSettings = true
            } label: {
                Text(prayerTimeManager.selectedCity?.name.uppercased() ?? "STANDORT")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.primary.opacity(0.85))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .liquidGlass()
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
