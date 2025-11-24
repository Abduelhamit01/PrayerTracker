//
//  ContentView.swift
//  TodoApp
//
//  Created by Abdülhamit Oral on 24.11.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Using Background Color")
                .foregroundColor(.white)
        }
        .accentColor(.purple)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.black
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
