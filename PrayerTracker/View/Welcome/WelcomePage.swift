//
//  WelcomePage.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 13.12.25.
//

import SwiftUI

struct WelcomePage: View {
        
    var body: some View {
        NavigationView {
            ZStack {
                // Hintergrund mit islamischem Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0/255, green: 100/255, blue: 80/255),
                        Color(red: 0/255, green: 60/255, blue: 80/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 120))
                        .foregroundStyle(.white.opacity(0.1))
                        .offset(x: 100, y: -50)
                    
                    Spacer()
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundStyle(.white.opacity(0.08))
                        .offset(x: -120, y: 50)
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Haupt-Icon
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 140, height: 140)
                        
                        Text("🤲🏼")
                            .font(.system(size: 60))
                            .foregroundStyle(.white)
                    }
                    .padding(.bottom, 40)
                    
                    // Bismillah
                    Text("بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)
                    
                    // App Titel
                    Text("Prayer Tracker")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 16)
                    
                    // Beschreibung
                    Text("Behalte deine fünf täglichen Gebete im Blick und baue eine starke spirituelle Routine auf")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 50)
                    
                    // Start Button
                    NavigationLink(destination: ContentView()) {
                        HStack(spacing: 10) {
                            Text("Bismillah")
                                .fontWeight(.semibold)
                                .font(.title3)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        .foregroundStyle(Color(red: 0/255, green: 100/255, blue: 80/255))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 18)
                        .background(.white)
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 30)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    WelcomePage()
}
