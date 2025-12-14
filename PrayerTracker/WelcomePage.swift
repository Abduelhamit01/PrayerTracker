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
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                
                ZStack {
                    Circle()
                        .foregroundStyle(.green.opacity(0.8))
                        .frame(width: 300)
                        .offset(x: width * 0.4, y: -height * 0.35)
                    
                    Circle()
                        .foregroundStyle(.orange.opacity(0.7))
                        .frame(width: 300)
                        .offset(x: width * 0.4, y: height * 0.3)
                    
                    Circle()
                        .foregroundStyle(.blue.opacity(0.6))
                        .frame(width: 300)
                        .offset(x: -width * 0.15, y: 0)
                    
                    Circle()
                        .foregroundStyle(.red.opacity(0.7))
                        .frame(width: 300)
                        .offset(x: -width * 0.35, y: -height * 0.45)
                    Circle()
                        .foregroundStyle(.yellow.opacity(0.6))
                        .frame(width: 300)
                        .offset(x: -width * 0.35, y: height * 0.45)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Prayer Tracker")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(.primary)
                        
                        Text("Track your prayers")
                            .font(.title2)
                            .foregroundStyle(.primary)
                        
                        NavigationLink(destination: ContentView()){
                            Text("Get started")
                            .foregroundStyle(.white)
                            .padding()
                            .fontWeight(.bold)
                            .background(.orange)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    WelcomePage()
}
