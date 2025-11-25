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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(prayers) { prayer in
                    DisclosureGroup {
                        ForEach(prayer.parts, id: \.self) { part in
                            HStack {
                                Text(part)
                                Spacer()
                                Image(systemName: isPartCompleted(prayerId: prayer.id, part: part) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isPartCompleted(prayerId: prayer.id, part: part) ? .green : .gray)
                                    .font(.system(size: 23))
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
                            Image(systemName: allCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(allCompleted ? .green : .gray)
                                .font(.system(size: 23))
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
