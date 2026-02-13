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

// MARK: - Liquid Glass Modifiers

extension View {
    /// Applies a Liquid Glass effect with capsule shape (iOS 26+, falls back to material on older versions)
    @ViewBuilder
    func liquidGlass(interactive: Bool = false, tint: Color? = nil) -> some View {
        if #available(iOS 26.0, *) {
            let baseGlass = Glass.regular
            let tintedGlass = tint != nil ? baseGlass.tint(tint!) : baseGlass
            let finalGlass = interactive ? tintedGlass.interactive() : tintedGlass
            
            self.glassEffect(finalGlass, in: .capsule)
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
    
    /// Applies a Liquid Glass effect with custom shape
    @ViewBuilder
    func liquidGlass<S: Shape>(
        in shape: S,
        interactive: Bool = false,
        tint: Color? = nil
    ) -> some View {
        if #available(iOS 26.0, *) {
            let baseGlass = Glass.regular
            let tintedGlass = tint != nil ? baseGlass.tint(tint!) : baseGlass
            let finalGlass = interactive ? tintedGlass.interactive() : tintedGlass
            
            self.glassEffect(finalGlass, in: shape)
        } else {
            self
                .background(.ultraThinMaterial)
                .clipShape(shape)
                .overlay(
                    shape
                        .stroke(.primary.opacity(0.15), lineWidth: 1)
                )
        }
    }
    
    /// Applies a prominent Liquid Glass effect (for important elements)
    @ViewBuilder
    func liquidGlassProminent(interactive: Bool = true) -> some View {
        if #available(iOS 26.0, *) {
            let glass = Glass.regular.tint(.islamicGreen.opacity(0.15)).interactive(interactive)
            self.glassEffect(glass, in: .rect(cornerRadius: 16))
        } else {
            self
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.islamicGreen.opacity(0.2), lineWidth: 1.5)
                )
        }
    }
}

struct GlassButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glass)
        } else {
            content
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
    @State private var showOnboarding: Bool = false
    @Environment(\.scenePhase) private var scenePhase
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
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(prayerTimeManager: prayerTimeManager)
        }
        .onAppear {
            // Onboarding hat Priorität
            if OnboardingManager.shouldShowOnboarding {
                showOnboarding = true
            } else if WhatsNewManager.shouldShowWhatsNew {
                showWhatsNew = true
                WhatsNewManager.markAsSeen()
            }
        }
    }


    // MARK: - Home Tab

    private var homeTab: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    WeekView(manager: manager)
                    
                    NextPrayerCountdownView(prayerTimeManager: prayerTimeManager)
                        .padding(.top, 4)

                    // Use GlassEffectContainer for prayer cards on iOS 26+
                    if #available(iOS 26.0, *) {
                        GlassEffectContainer(spacing: 12) {
                            prayerCardsList
                        }
                    } else {
                        prayerCardsList
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
                                        .liquidGlass(in: Circle(), interactive: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                }
            }
            .task {
                await prayerTimeManager.fetchTodaysTimes()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    Task {
                        await prayerTimeManager.fetchTodaysTimes()
                    }
                }
            }
        }
        .tabItem {
            Label("Home", systemImage: "house")
        }
    }
    
    // MARK: - Prayer Cards List
    
    @ViewBuilder
    private var prayerCardsList: some View {
        VStack(spacing: 12) {
            ForEach(manager.prayers) { prayer in
                PrayerCard(
                    prayer: prayer,
                    manager: manager,
                    prayerTimeManager: prayerTimeManager,
                    onPartTap: { part in handlePartTap(prayer: prayer, part: part) }
                )
            }
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
                .modifier(GlassButtonModifier())
            }
        }

        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 18))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .liquidGlass(in: Circle(), interactive: true)
            }
            .buttonStyle(.plain)
        }

        ToolbarItem(placement: .principal) {
            Button {
                showSettings = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11, weight: .semibold))
                    
                    Text(prayerTimeManager.selectedCity?.displayName.uppercased() ?? String(localized: "location_placeholder"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(1.2)
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .liquidGlass(interactive: true)
            }
            .buttonStyle(.plain)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
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
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .liquidGlass(in: Circle(), interactive: true)
            }
            .buttonStyle(.plain)
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
