//
//  ContentView.swift
//  TodoApp
//
//  Created by Abdülhamit Oral on 24.11.25.
//

import SwiftUI
import ConfettiSwiftUI

enum PrayerColor {
    static func color(for prayerName: String) -> Color {
        switch prayerName.lowercased() {
        case "fajr":
            return Color(red: 100/255, green: 150/255, blue: 200/255) // Morgenblau
        case "dhuhr":
            return Color(red: 255/255, green: 200/255, blue: 50/255) // Sonnengelb
        case "asr":
            return Color(red: 255/255, green: 140/255, blue: 60/255) // Orange
        case "maghrib":
            return Color(red: 230/255, green: 100/255, blue: 120/255) // Sonnenuntergang-Rosa
        case "isha":
            return Color(red: 120/255, green: 80/255, blue: 160/255) // Nachtlila
        default:
            return Color.gray
        }
    }
    
    static func gradient(for prayerName: String) -> LinearGradient {
        let baseColor = color(for: prayerName)
        return LinearGradient(
            gradient: Gradient(colors: [baseColor.opacity(0.6), baseColor.opacity(0.3)]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct ContentView: View {
    @StateObject private var manager = PrayerManager()
    @State private var trigger: Int = 0
    
    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "de_DE")
        
        if Calendar.current.isDateInToday(manager.selectedDate) {
            return "Heute"
        } else if Calendar.current.isDateInYesterday(manager.selectedDate) {
            return "Gestern"
        } else {
            return formatter.string(from: manager.selectedDate)
        }
    }
    
    var body: some View {
        
        TabView {
            NavigationStack {
                List {
                    WeekView(manager: manager)
                        .padding(.top)
                    ForEach(manager.prayers) { prayer in
                        PrayerRow(
                            prayer: prayer,
                            manager: manager,
                            onPartTap: { part in handlePartTap(prayer: prayer, part: part) },
                            onPrayerTap: { handlePrayerTap(prayer: prayer) }
                        )
                    }
                }
                
                .listStyle(.plain)
                .navigationTitle("PrayerTracker")
                .toolbar {
                    // Button, um schnell zu "Heute" zurückzukehren
                    if !Calendar.current.isDateInToday(manager.selectedDate) {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Heute") {
                                withAnimation {
                                    manager.selectedDate = Date()
                                }
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("", systemImage: "trash.fill") {
                            manager.clearAllCompletions()
                        }
                    }
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            NavigationStack {
                Text("")
            }
            .tabItem {
                Label("History", systemImage: "calendar")
            }
            NavigationStack {
                Text("Account")
            }
            .tabItem {
                Label("Setting", systemImage: "gear")
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

    }
    
    private func handlePartTap(prayer: Prayer, part: String) {
        let wereAllCompleted = manager.isAllCompleted(prayer: prayer)
        manager.togglePartCompletion(prayerId: prayer.id, part: part)
        let areAllCompletedNow = manager.isAllCompleted(prayer: prayer)
        
        if !wereAllCompleted && areAllCompletedNow {
            trigger += 1
        }
    }
    
    private func handlePrayerTap(prayer: Prayer) {
        let wasCompleted = manager.isAllCompleted(prayer: prayer)
        let willBeCompleted = !wasCompleted
        
        manager.setAllParts(of: prayer, to: willBeCompleted)
        
        if willBeCompleted {
            trigger += 1
        }
    }
}

#Preview {
    ContentView()
}
