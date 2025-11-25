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
    
    static let fajr = Prayer(name:"Fajr", parts: ["Sunnah, Fardh"])
    static let example1 = Prayer(name: "Fajr", parts: ["Sunnah", "Fardh"])
}

struct ContentView: View {
    @State private var completedPrayers: Set<String> = []
            
    let prayer: [Prayer] = [.example1]
    
    var body: some View {
        VStack {
            NavigationStack{
                List {
                    ForEach(prayer) { prayer in
                        HStack{
                            Text(prayer.name)
                            Spacer()
                            Image(systemName: completedPrayers.contains(prayer) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(completedPrayers.contains(prayer) ? .green : .gray)
                                .font(.system(size: 23))
                        }
                        .onTapGesture{
                            if completedPrayers.contains(prayer){
                                completedPrayers.remove(prayer.name)
                            } else {
                                completedPrayers.insert(prayer)
                            }
                        }
                    }
                }
                .navigationTitle("Prayer")
            }
        }
    }
}

#Preview {
    ContentView()
}
