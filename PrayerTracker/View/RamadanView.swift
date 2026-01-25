//
//  RamadanView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 24.01.26.
//

import SwiftUI
import AVFoundation
import ConfettiSwiftUI

struct RamadanView: View {
    @ObservedObject var manager: PrayerManager
    @ObservedObject var ramadanManager: RamadanManager
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) private var colorScheme

    @State private var dragOffset: CGFloat = 0
    @State private var confettiTrigger: Int = 0

    private let sliderWidth: CGFloat = 300
    private let knobSize: CGFloat = 50
    private let islamicGreen = Color("IslamicGreen")

    // Grünes Farbschema
    private var backgroundGradient: LinearGradient {
        if colorScheme == .dark {
            // Dunkles Grün - von oben hell nach unten dunkel
            return LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.22, blue: 0.18),
                    Color(red: 0.0, green: 0.12, blue: 0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            // Helles Grün
            return LinearGradient(
                colors: [
                    Color(red: 0.88, green: 0.95, blue: 0.90),
                    Color(red: 0.78, green: 0.90, blue: 0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.0, green: 0.18, blue: 0.14)
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.7) : Color(red: 0.2, green: 0.35, blue: 0.30)
    }

    private var sliderTrackColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : islamicGreen.opacity(0.15)
    }

    private var sliderTextColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.5) : islamicGreen.opacity(0.6)
    }

    // Mond-Farben - Gold/Amber für Kontrast gegen Grün
    private var moonColor: Color {
        Color(red: 1.0, green: 0.85, blue: 0.4) // Warmes Gold
    }

    private var starColor: Color {
        Color(red: 1.0, green: 0.78, blue: 0.3) // Amber
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Hintergrund
            backgroundGradient
                .ignoresSafeArea()

            // Hauptinhalt
            VStack(spacing: 0) {
                // Top Bar mit Zurück Button
                HStack {
                    // Zurück Button (Liquid Glass Style)
                    backButton
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()

                // Mond Illustration
                moonIllustration
                    .padding(.bottom, 24)

                // Titel
                Text("Ramadan")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
                    .padding(.bottom, 8)

                if !ramadanManager.isRamadanActive {
                    let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: ramadanManager.ramadanStart).day ?? 0
                    Text("Startet in \(daysUntil) Tagen")
                        .font(.headline)
                        .foregroundColor(secondaryTextColor)
                        .padding(.bottom, 4)
                    
                    RamadanTimelineView(
                        currentDay: ramadanManager.isRamadanActive ? ramadanManager.currentDay : 0,
                        ramadanStart: ramadanManager.ramadanStart
                    )
                    .padding(.vertical, 10)
                } else {
                    // Fallback für "Noch X Tage", falls Ramadan noch nicht begonnen hat
                    VStack(spacing: 8) {
                        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: ramadanManager.ramadanStart).day ?? 0
                        Text("Noch \(daysUntil) Tage")
                            .font(.headline)
                            .foregroundColor(secondaryTextColor)
                        
                        // Kleine Vorschau der Mondphasen als Deko
                        HStack(spacing: 15) {
                            Image(systemName: "moonphase.waxing.crescent")
                            Image(systemName: "moonphase.first.quarter")
                            Image(systemName: "moonphase.full.moon")
                            Image(systemName: "moonphase.last.quarter")
                        }
                        .font(.title2)
                        .foregroundStyle(secondaryTextColor.opacity(0.5))
                    }
                    .padding(.vertical, 20)
                }
                // --------------------------

                Spacer()

                // Slider oder Completed State
                sliderSection
                    .padding(.top, 16)
                    .padding(.bottom, 40)

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .confettiCannon(
            trigger: $confettiTrigger,
            confettis: [.text("🌙"), .text("⭐"), .text("✨"), .text("🤲")],
            confettiSize: 12,
            rainHeight: 600,
            radius: 400,
            repetitionInterval: 0.1
        )
    }

    // MARK: - Mond Illustration

    private var moonIllustration: some View {
        ZStack {
            // Starker Glow für bessere Sichtbarkeit
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            moonColor.opacity(0.4),
                            moonColor.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)

            // Mond mit Sternen - Gold/Amber
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 100))
                .symbolRenderingMode(.palette)
                .foregroundStyle(moonColor, starColor)
                .shadow(color: moonColor.opacity(0.6), radius: 20)
        }
    }

    // MARK: - Back Button

    @ViewBuilder
    private var backButton: some View {
        if #available(iOS 26.0, *) {
            Button {
                selectedTab = 0
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textColor)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.regular, in: .circle)
        } else {
            Button {
                selectedTab = 0
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textColor)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
        }
    }

    // MARK: - Slider Section

    private var sliderSection: some View {
        VStack(spacing: 16) {
            if ramadanManager.todayCompleted {
                // Completed State
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(islamicGreen)

                    Text("Alhamdulillah!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(textColor)

                    Button {
                        withAnimation {
                            ramadanManager.uncompleteToday()
                            dragOffset = 0
                        }
                    } label: {
                        Text("Rückgängig")
                            .font(.caption)
                            .foregroundColor(islamicGreen)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(islamicGreen.opacity(0.15))
                            .cornerRadius(20)
                    }
                    .padding(.top, 8)
                }
            } else {
                // Slider
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 30)
                        .fill(sliderTrackColor)
                        .frame(width: sliderWidth, height: 60)

                    // Text
                    Text("Alhamdulillah")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(sliderTextColor)
                        .frame(width: sliderWidth, height: 60)

                    // Knob mit Checkmark
                    Circle()
                        .fill(islamicGreen)
                        .frame(width: knobSize, height: knobSize)
                        .overlay(
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                        )
                        .offset(x: dragOffset + 5)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let maxOffset = sliderWidth - knobSize - 10
                                    dragOffset = max(0, min(value.translation.width, maxOffset))
                                }
                                .onEnded { _ in
                                    let maxOffset = sliderWidth - knobSize - 10
                                    if dragOffset > maxOffset * 0.7 {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            dragOffset = maxOffset
                                        }
                                        completeToday()
                                    } else {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                }
            }
        }
    }

    // MARK: - Actions

    private func completeToday() {
        ramadanManager.completeToday()
        confettiTrigger += 1
        manager.playSuccessSound()
    }
}

#Preview {
    RamadanView(manager: PrayerManager(), ramadanManager: RamadanManager(), selectedTab: .constant(1))
}

