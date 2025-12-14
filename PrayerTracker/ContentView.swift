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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(manager.prayers) { prayer in
                    DisclosureGroup {
                        ForEach(prayer.parts, id: \.self) { part in
                            HStack (spacing: 12) {
                                Text("📿")
                                    .font(.system(size: 40))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(part)
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                                Spacer()
                                checkMarkImage(isCompleted: manager.isPartCompleted(prayerId: prayer.id, part: part))
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                handlePartTap(prayer: prayer, part: part)
                            }
                        }
                    } label: {
                        HStack(spacing: 30) {
                            Text(prayer.emoji)
                                .font(.system(size: 50))
                            VStack {
                                Text(prayer.name)
                                    .foregroundStyle(.primary)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                let completedCount = prayer.parts.filter { part in
                                    manager.isPartCompleted(prayerId: prayer.id, part: part)
                                } .count
                                
                                Text("\(completedCount) von \(prayer.parts.count) erledigt")
                            }
                            Spacer()
                            
                            checkMarkImage(isCompleted: manager.isAllCompleted(prayer: prayer))
                        }
                        .padding(.vertical, 10)
                        .onTapGesture {
                            handlePrayerTap(prayer: prayer)
                        }
                    }
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                )
            }
            .navigationTitle("Gebetszeiten")
            .toolbar {
                Button("", systemImage: "trash.fill") {
                    manager.clearAllCompletions()
                }
            }
        }
        .confettiCannon(
            trigger: $trigger,
            confettis: [.text("🤲"), .text("🕌"), .text("🌟"), .text("✨"), .text("📿"), .text("🥳")],
            confettiSize: 15,
            rainHeight: 1000,
            radius: 400,
            repetitionInterval: 0.3
        )
    }
    
    // Hilfsfunktion für übersichtlichere Tap-Behandlung
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
    
    private func checkMarkImage(isCompleted: Bool) -> some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(isCompleted ? .green : .gray)
            .font(.system(size: 20))
    }
}

#Preview {
    ContentView()
}
