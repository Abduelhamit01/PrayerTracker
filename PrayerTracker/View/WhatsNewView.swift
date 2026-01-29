//
//  WhatsNewView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 29.01.26.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var cardBackground: Color {
        colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Header
            VStack(spacing: 8) {
                Text("🕌")
                    .font(.system(size: 50))

                Text("whats_new_bismillah")
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "moon.stars.fill", text: "whats_new_feature_1")
                FeatureRow(icon: "person.badge.plus", text: "whats_new_feature_2")
                FeatureRow(icon: "clock.fill", text: "whats_new_feature_3")
                FeatureRow(icon: "bell.fill", text: "whats_new_feature_4")
                FeatureRow(icon: "location.fill", text: "whats_new_feature_5")
            }
            .padding(20)
            .background(cardBackground)
            .cornerRadius(16)

            // Footer
            Text("whats_new_alhamdulillah")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            // Button
            Button {
                dismiss()
            } label: {
                Text("whats_new_understood")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.islamicGreen)
                    .cornerRadius(14)
            }
        }
        .padding(24)
        .background(Color(.systemGroupedBackground))
        .interactiveDismissDisabled()
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.islamicGreen)
                .frame(width: 32)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Version Check

struct WhatsNewManager {
    private static let lastSeenVersionKey = "lastSeenAppVersion"

    static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    static var shouldShowWhatsNew: Bool {
        let lastSeen = UserDefaults.standard.string(forKey: lastSeenVersionKey)
        return lastSeen != currentVersion
    }

    static func markAsSeen() {
        UserDefaults.standard.set(currentVersion, forKey: lastSeenVersionKey)
    }
}

#Preview {
    WhatsNewView()
}
