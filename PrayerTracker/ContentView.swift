//
//  ContentView.swift
//  TodoApp
//
//  Created by Abdülhamit Oral on 24.11.25.
//

import SwiftUI

struct Prayer: Identifiable {
    let id = UUID()
    let name: String
    let parts: [String]
}

struct ContentView: View {
    
    @State private var completedPartsOfPrayer: Set<String> = []
    
    let prayers: [Prayer] = [
        Prayer(name: "Fajr",     parts: ["Sunnah", "Fardh"]),
        Prayer(name: "Dhuhr",    parts: ["Sunnah", "Fardh"]),
        Prayer(name: "Asr",      parts: ["Sunnah", "Fardh"]),
        Prayer(name: "Maghrib",  parts: ["Fardh", "Sunnah"]),
        Prayer(name: "Isha",     parts: ["Fardh", "Sunnah", "Witr"])
    ]
    
    private func isPartCompleted(prayerId: UUID, part: String) -> Bool {
        completedPartsOfPrayer.contains("\(prayerId)-\(part)")
    }
    
    private func checkMarkImage(isComleted: Bool) -> some View {
        Image(systemName: isComleted ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(isComleted ? .green : .gray)
            .font(.system(size: 23))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(prayers) { prayer in
                    DisclosureGroup {
                        ForEach(prayer.parts, id: \.self) { part in
                            HStack {
                                Text(part)
                                Spacer()
                                checkMarkImage(isComleted: isPartCompleted(prayerId: prayer.id, part: part))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                let key = "\(prayer.id)-\(part)"
                                if completedPartsOfPrayer.contains(key) {
                                    completedPartsOfPrayer.remove(key)
                                } else {
                                    completedPartsOfPrayer.insert(key)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(prayer.name)
                            Spacer()
                            let allCompleted = prayer.parts.allSatisfy {
                                isPartCompleted(prayerId: prayer.id, part: $0)
                            }
                            checkMarkImage(isComleted: allCompleted)
                        }
                    }
                }
                .navigationTitle("Gebetszeiten")
            }
        }
    }
}



#Preview {
    ContentView()
}
