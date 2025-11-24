//
//  ContentView.swift
//  TodoApp
//
//  Created by Abdülhamit Oral on 24.11.25.
//

import SwiftUI

struct ContentView: View {
    @State private var completedPrayers: Set<String> = []
    
    let prayers = ["Fajr", "Dhur", "Asr", "Maghirb", "Isha"]
    
    var body: some View {
        VStack {
            NavigationStack{
                List {
                    ForEach(prayers, id:  \.self) { prayer in
                        HStack{
                            Text(prayer)
                            Spacer()
                            Image(systemName: completedPrayers.contains(prayer) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(completedPrayers.contains(prayer) ? .green : .gray)
                        }
                        .onTapGesture{
                            if completedPrayers.contains(prayer){
                                completedPrayers.remove(prayer)
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
