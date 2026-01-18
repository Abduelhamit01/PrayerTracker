//
//  SplashScreenView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 17.01.26.
//

import SwiftUI

struct SplashScreenView: View {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showSplash = true
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0.5

    var body: some View {
        if showSplash {
            splashContent
                .onAppear {
                    // Icon Animation
                    withAnimation(.easeOut(duration: 0.8)) {
                        iconScale = 1.0
                        iconOpacity = 1.0
                    }

                    // Nach 1.5 Sekunden zur App wechseln
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSplash = false
                        }
                    }
                }
        } else if hasSeenWelcome {
            ContentView()
        } else {
            WelcomePage(onComplete: {
                hasSeenWelcome = true
            })
        }
    }

    private var splashContent: some View {
        ZStack {
            // Hintergrund
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // App Icon
                Image("LaunchIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                // App Name
                Text("Prayer Tracker")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.islamicGreen)
                    .opacity(iconOpacity)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
