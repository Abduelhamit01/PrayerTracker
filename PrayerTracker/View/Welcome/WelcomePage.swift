//
//  WelcomePage.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 13.12.25.
//

import SwiftUI

struct WelcomePage: View {
    let onComplete: () -> Void

    // Animation States
    @State private var moonOffset: CGFloat = 80
    @State private var moonOpacity: Double = 0
    @State private var starsOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var moonGlow: Bool = false
    @State private var starsTwinkle: Bool = false

    // Colors
    private let deepGreen = Color(red: 0.02, green: 0.12, blue: 0.10)
    private let islamicGreen = Color(red: 0.0, green: 0.40, blue: 0.30)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundGradient

                // Geometric pattern overlay
                GeometricPatternView()
                    .opacity(0.025)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Moon with stars
                    moonSection
                        .frame(height: geometry.size.height * 0.38)

                    // Text content
                    textSection

                    Spacer()

                    // Start button
                    startButton
                        .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                deepGreen,
                islamicGreen.opacity(0.6),
                deepGreen
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Moon Section

    private var moonSection: some View {
        ZStack {
            // Stars scattered around
            ForEach(0..<15, id: \.self) { i in
                let positions: [(CGFloat, CGFloat)] = [
                    (-90, -70), (100, -50), (-60, 40), (80, -90), (-110, 20),
                    (50, 60), (-40, -100), (120, 30), (-80, 80), (95, -30),
                    (-100, -40), (60, 90), (-30, -80), (110, 70), (-70, 50)
                ]

                Circle()
                    .fill(.white)
                    .frame(width: [2, 3, 2, 4, 2, 3, 2, 3, 4, 2, 3, 2, 3, 2, 4][i])
                    .offset(x: positions[i].0, y: positions[i].1)
                    .opacity(starsOpacity * (starsTwinkle ? [0.9, 0.5, 0.8, 0.6, 0.9, 0.4, 0.7, 0.5, 0.8, 0.6, 0.9, 0.7, 0.5, 0.8, 0.6][i] : [0.5, 0.9, 0.6, 0.8, 0.5, 0.9, 0.4, 0.8, 0.5, 0.9, 0.6, 0.4, 0.8, 0.5, 0.9][i]))
            }

            // Moon glow effect (subtiler)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 30,
                        endRadius: moonGlow ? 80 : 70
                    )
                )
                .frame(width: 160, height: 160)

            // Crescent moon
            Image(systemName: "moon.fill")
                .font(.system(size: 70, weight: .thin))
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.4), radius: 12)
        }
        .offset(y: moonOffset)
        .opacity(moonOpacity)
    }

    // MARK: - Text Section

    private var textSection: some View {
        VStack(spacing: 20) {
            // Bismillah in Arabic
            Text("بِسْمِ اللّٰهِ")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.bottom, 8)

            // App name
            Text("Prayer Tracker")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            // Tagline
            Text("Deine spirituelle Begleitung\nfür ein achtsames Gebetsleben")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.top, 4)
        }
        .opacity(textOpacity)
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.25)) {
                onComplete()
            }
        }) {
            Text("Beginnen")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(deepGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white)
                )
                .padding(.horizontal, 50)
        }
        .opacity(buttonOpacity)
    }

    // MARK: - Animations

    private func startAnimations() {
        // Moon rises
        withAnimation(.easeOut(duration: 1.0)) {
            moonOffset = 0
            moonOpacity = 1
        }

        // Stars appear
        withAnimation(.easeOut(duration: 0.7).delay(0.4)) {
            starsOpacity = 1
        }

        // Text fades in
        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            textOpacity = 1
        }

        // Button appears
        withAnimation(.easeOut(duration: 0.4).delay(1.0)) {
            buttonOpacity = 1
        }

        // Continuous animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            // Moon glow pulse
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                moonGlow = true
            }
            // Stars twinkle
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                starsTwinkle = true
            }
        }
    }
}

// MARK: - Islamic Geometric Pattern

struct GeometricPatternView: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 50
            let rows = Int(size.height / spacing) + 2
            let cols = Int(size.width / spacing) + 2

            for row in 0..<rows {
                for col in 0..<cols {
                    let x = CGFloat(col) * spacing
                    let y = CGFloat(row) * spacing

                    // Draw 8-pointed star
                    let starPath = createStarPath(center: CGPoint(x: x, y: y), size: 12)
                    context.stroke(starPath, with: .color(.white), lineWidth: 0.5)
                }
            }
        }
    }

    private func createStarPath(center: CGPoint, size: CGFloat) -> Path {
        Path { path in
            // 8-pointed star
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4 - .pi / 8
                let x = center.x + CGFloat(cos(angle)) * size
                let y = center.y + CGFloat(sin(angle)) * size

                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()

            // Inner octagon
            let innerSize = size * 0.5
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4
                let x = center.x + CGFloat(cos(angle)) * innerSize
                let y = center.y + CGFloat(sin(angle)) * innerSize

                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
        }
    }
}

#Preview {
    WelcomePage(onComplete: {})
}
