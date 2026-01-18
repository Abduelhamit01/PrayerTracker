//
//  SettingsView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 08.01.26.
//

import SwiftUI

enum AppAppearance: String, CaseIterable {
    case light
    case dark
    case system

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    var localizedName: LocalizedStringKey {
        switch self {
        case .light: return "light"
        case .dark: return "dark"
        case .system: return "system"
        }
    }
}

struct SettingsView: View {
    @State private var showDeleteAlert = false
    @AppStorage("appAppearance") private var appearanceRaw: String = AppAppearance.system.rawValue

    private var appearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceRaw) ?? .system }
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Appearance Section
                Section(header: Text("design")) {
                    HStack(spacing: 12) {
                        ForEach(AppAppearance.allCases, id: \.self) { mode in
                            appearanceCard(mode)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section(header: Text("data"), footer: Text("delete_data_warning")) {
                    Button("delete_all_data", role: .destructive) {
                        showDeleteAlert = true
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle(Text("settings"))
            .alert("warning_data_deleted", isPresented: $showDeleteAlert) {
                Button("cancel", role: .cancel) { }
                Button("delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("data_cannot_recover")
            }
        }
    }
    
    private func deleteAllData() {
        // Speichere hasSeenWelcome, damit die Welcome-Seite nicht erneut angezeigt wird
        let hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcome")

        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }

        // Stelle hasSeenWelcome wieder her
        UserDefaults.standard.set(hasSeenWelcome, forKey: "hasSeenWelcome")
        appearanceRaw = AppAppearance.system.rawValue

        // Benachrichtige PrayerManager, dass Daten gelöscht wurden
        NotificationCenter.default.post(name: .didClearAllData, object: nil)
    }

    // MARK: - Appearance Card

    private func appearanceCard(_ mode: AppAppearance) -> some View {
        let isSelected = appearance == mode
        let accentColor = Color(red: 0.0, green: 0.45, blue: 0.35)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                appearanceRaw = mode.rawValue
            }
        } label: {
            VStack(spacing: 10) {
                // Mockup
                phoneMockup(for: mode)
                    .frame(width: 80, height: 55)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? accentColor : Color.clear, lineWidth: 3)
                    )

                Text(mode.localizedName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? accentColor : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Phone Mockups

    @ViewBuilder
    private func phoneMockup(for mode: AppAppearance) -> some View {
        switch mode {
        case .light:
            ZStack {
                LinearGradient(colors: [Color(white: 0.95), Color(white: 0.85)], startPoint: .top, endPoint: .bottom)
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white)
                    .frame(width: 30, height: 40)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                    .overlay(mockupLines(light: true))
            }

        case .dark:
            ZStack {
                LinearGradient(colors: [Color(white: 0.15), Color(white: 0.05)], startPoint: .top, endPoint: .bottom)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(white: 0.12))
                    .frame(width: 30, height: 40)
                    .overlay(mockupLines(light: false))
            }

        case .system:
            HStack(spacing: 0) {
                // Light half
                ZStack {
                    Color(white: 0.9)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white)
                        .frame(width: 22, height: 34)
                        .overlay(mockupLines(light: true))
                }
                // Dark half
                ZStack {
                    Color(white: 0.1)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(white: 0.15))
                        .frame(width: 22, height: 34)
                        .overlay(mockupLines(light: false))
                }
            }
        }
    }

    private func mockupLines(light: Bool) -> some View {
        VStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 1)
                .fill(light ? Color(white: 0.85) : Color(white: 0.3))
                .frame(height: 4)
            RoundedRectangle(cornerRadius: 1)
                .fill(light ? Color(white: 0.85) : Color(white: 0.3))
                .frame(height: 4)
            RoundedRectangle(cornerRadius: 1)
                .fill(light ? Color(white: 0.85) : Color(white: 0.3))
                .frame(height: 4)
            Spacer()
        }
        .padding(4)
    }
}

#Preview {
    SettingsView()
}
