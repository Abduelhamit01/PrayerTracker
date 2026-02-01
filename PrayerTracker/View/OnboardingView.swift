//
//  OnboardingView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 29.01.26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var prayerTimeManager: PrayerTimeManager

    @State private var currentStep: OnboardingStep = .welcome
    @State private var showLocationPicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressIndicator
                    .padding(.top, 20)

                Spacer()

                Group {
                    switch currentStep {
                    case .welcome:
                        welcomeContent
                    case .location:
                        locationContent
                    case .notifications:
                        notificationContent
                    case .complete:
                        completeContent
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer()

                actionButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .interactiveDismissDisabled()
            .sheet(isPresented: $showLocationPicker) {
                NavigationStack {
                    LocationSelectionView(prayerTimeManager: prayerTimeManager) {
                        showLocationPicker = false
                        withAnimation(.spring(duration: 0.4)) {
                            currentStep = .notifications
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("cancel") {
                                showLocationPicker = false
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingStep.allCases, id: \.self) { step in
                Capsule()
                    .fill(step.rawValue <= currentStep.rawValue ? Color.islamicGreen : Color.gray.opacity(0.3))
                    .frame(width: step == currentStep ? 24 : 8, height: 8)
                    .animation(.spring(duration: 0.3), value: currentStep)
            }
        }
    }

    // MARK: - Welcome Content

    private var welcomeContent: some View {
        VStack(spacing: 24) {
            Text("🕌")
                .font(.system(size: 80))

            VStack(spacing: 12) {
                Text("onboarding_bismillah")
                    .font(.title)
                    .fontWeight(.bold)

                Text("onboarding_welcome_subtitle")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Location Content

    private var locationContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.fill")
                .font(.system(size: 60))
                .foregroundStyle(.islamicGreen)

            VStack(spacing: 12) {
                Text("onboarding_location_title")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("onboarding_location_subtitle")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            if let city = prayerTimeManager.selectedCity {
                Label(city.displayName, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.islamicGreen)
                    .font(.subheadline)
            }
        }
    }

    // MARK: - Notification Content

    private var notificationContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.fill")
                .font(.system(size: 60))
                .foregroundStyle(.islamicGreen)

            VStack(spacing: 12) {
                Text("onboarding_notification_title")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("onboarding_notification_subtitle")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Complete Content

    private var completeContent: some View {
        VStack(spacing: 24) {
            Text("✨")
                .font(.system(size: 80))

            VStack(spacing: 12) {
                Text("onboarding_complete_title")
                    .font(.title)
                    .fontWeight(.bold)

                Text("onboarding_alhamdulillah")
                    .font(.title3)
                    .foregroundStyle(.islamicGreen)

                Text("onboarding_complete_subtitle")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Action Button

    @ViewBuilder
    private var actionButton: some View {
        switch currentStep {
        case .welcome:
            primaryButton(title: "onboarding_continue") {
                withAnimation(.spring(duration: 0.4)) {
                    currentStep = .location
                }
            }

        case .location:
            VStack(spacing: 12) {
                if prayerTimeManager.selectedCity == nil {
                    primaryButton(title: "onboarding_select_location") {
                        showLocationPicker = true
                    }

                    secondaryButton(title: "onboarding_skip") {
                        withAnimation(.spring(duration: 0.4)) {
                            currentStep = .notifications
                        }
                    }
                } else {
                    primaryButton(title: "onboarding_continue") {
                        withAnimation(.spring(duration: 0.4)) {
                            currentStep = .notifications
                        }
                    }

                    secondaryButton(title: "onboarding_change_location") {
                        showLocationPicker = true
                    }
                }
            }

        case .notifications:
            VStack(spacing: 12) {
                primaryButton(title: "onboarding_enable_notifications") {
                    Task {
                        await enableNotifications()
                    }
                }

                secondaryButton(title: "onboarding_skip") {
                    withAnimation(.spring(duration: 0.4)) {
                        currentStep = .complete
                    }
                }
            }

        case .complete:
            primaryButton(title: "onboarding_start") {
                OnboardingManager.markAsCompleted()
                dismiss()
            }
        }
    }

    // MARK: - Button Helpers

    private func primaryButton(title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.islamicGreen)
                .cornerRadius(14)
        }
    }

    private func secondaryButton(title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Enable Notifications

    private func enableNotifications() async {
        let granted = await PrayerNotificationManager.shared.requestAuthorization()

        if granted {
            // App-internen Toggle aktivieren
            UserDefaults.standard.set(true, forKey: "notificationsEnabled")

            // Sofort Benachrichtigungen planen (falls Standort gewählt)
            if let times = prayerTimeManager.todaysTimes,
               let cityName = prayerTimeManager.selectedCity?.name {
                await PrayerNotificationManager.shared.scheduleNotifications(
                    for: times,
                    cityName: cityName
                )
            }
        }

        // Weiter zum nächsten Schritt
        await MainActor.run {
            withAnimation(.spring(duration: 0.4)) {
                currentStep = .complete
            }
        }
    }
}

// MARK: - Onboarding Step

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case location = 1
    case notifications = 2
    case complete = 3
}

// MARK: - Onboarding Manager

struct OnboardingManager {
    private static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private static let onboardingVersionKey = "onboardingVersion"
    private static let currentOnboardingVersion = 1

    static var shouldShowOnboarding: Bool {
        let hasCompleted = UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        let lastVersion = UserDefaults.standard.integer(forKey: onboardingVersionKey)
        return !hasCompleted || lastVersion < currentOnboardingVersion
    }

    static func markAsCompleted() {
        UserDefaults.standard.set(true, forKey: hasCompletedOnboardingKey)
        UserDefaults.standard.set(currentOnboardingVersion, forKey: onboardingVersionKey)
    }
}

#Preview {
    OnboardingView(prayerTimeManager: PrayerTimeManager())
}
