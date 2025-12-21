//
//  ContentView.swift
//  TodoApp
//
//  Created by Abdülhamit Oral on 24.11.25.
//

import SwiftUI
import ConfettiSwiftUI

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
