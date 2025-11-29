//
//  ContentView.swift
//  TodoApp
//
//  Created by Abdülhamit Oral on 24.11.25.
//

import SwiftUI

struct Prayer: Identifiable {
    let id: String  // String statt UUID
    let name: String
    let parts: [String]
}

struct ContentView: View {
    
    @AppStorage("completedParts") private var completedPartsData: Data = Data()
    
    let prayers: [Prayer] = [
        Prayer(id: "fajr", name: "Fajr", parts: ["Sunnah", "Fardh"]),
        Prayer(id: "dhuhr", name: "Dhuhr", parts: ["Sunnah", "Fardh"]),
        Prayer(id: "asr", name: "Asr", parts: ["Sunnah", "Fardh"]),
        Prayer(id: "maghrib", name: "Maghrib", parts: ["Fardh", "Sunnah"]),
        Prayer(id: "isha", name: "Isha", parts: ["Fardh", "Sunnah", "Witr"])
    ]
    
    private func isPartCompleted(prayerId: String, part: String) -> Bool {
        let key = "\(prayerId)-\(part)"
        return completedParts.contains(key)
    }
    
    private func checkMarkImage(isCompleted: Bool) -> some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(isCompleted ? .green : .gray)
            .font(.system(size: 23))
    }
    
    private func setAllParts(of prayer: Prayer, to complete: Bool ){
        for part in prayer.parts {
            let key = "\(prayer.id)-\(part)"
            let isCurrentlyCompleted = completedParts.contains(key)
            
            if complete && !isCurrentlyCompleted {
                addKey(key)
            }else if !complete && isCurrentlyCompleted {
                removeKey(key)
            }
        }
    }
    
    private func togglePartCompletion(key: String) {
        if completedParts.contains(key) {
            removeKey(key)
        } else {
            addKey(key)
        }
    }
    
    private var completedParts: Set<String> {
        guard let decoded = try? JSONDecoder().decode(Set<String>.self, from: completedPartsData) else {
            return []
        }
        return decoded
    }

    private func updateCompletedParts(_ newSet: Set<String>) {
        guard let encoded = try? JSONEncoder().encode(newSet) else { return }
        completedPartsData = encoded
    }

    private func addKey(_ key: String) {
        var parts = completedParts
        parts.insert(key)
        updateCompletedParts(parts)
    }

    private func removeKey(_ key: String) {
        var parts = completedParts
        parts.remove(key)
        updateCompletedParts(parts)
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
                                checkMarkImage(isCompleted: isPartCompleted(prayerId: prayer.id, part: part))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                let key = "\(prayer.id)-\(part)"
                                togglePartCompletion(key: key)
                            }
                        }
                    } label: {
                        HStack {
                            Text(prayer.name)
                            Spacer()
                            let allCompleted = prayer.parts.allSatisfy {
                                isPartCompleted(prayerId: prayer.id, part: $0)
                            }
                            checkMarkImage(isCompleted: allCompleted)
                            
                        }
                        .onTapGesture {
                            let allCompleted = prayer.parts.allSatisfy{
                                isPartCompleted(prayerId: prayer.id, part: $0)
                            }
                                setAllParts(of: prayer, to: !allCompleted)
                        }
                    }
                    
                }
            }
            .navigationTitle("Gebetszeiten")
        }
    }
}



#Preview {
    ContentView()
}
