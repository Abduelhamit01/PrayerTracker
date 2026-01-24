//
//  RamadanView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 24.01.26.
//

import SwiftUI
import AVFoundation

struct RamadanView: View {
    @ObservedObject var manager: PrayerManager

    @State private var dragOffset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @State private var isCompleted = false

    var body: some View {
        if isCompleted {
            VStack{
                Text("Hallo")
            }
        } else {
            ZStack(alignment: .leading){
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: 300, height: 60)
                        .padding(.leading, 0)

                Text("Alhamdulillah")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.leading, 16)
                
                Circle()
                    .fill(.red)
                    .frame(width: 50, height: 50)
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged {
                                value in
                                dragOffset = max(0, min(lastOffset + value.translation.width, 250))
                            }
                            .onEnded {_ in
                                if dragOffset > 200 {
                                    withAnimation(.spring) {
                                        dragOffset = 250
                                        lastOffset = dragOffset
                                        manager.playSuccessSound()
                                    }
                                    isCompleted = true
                                } else {
                                    print("Nicht Erfolgreich")
                                    withAnimation(.spring){
                                        dragOffset = 0
                                        lastOffset = 0
                                    }
                                }
                            }
                    )
            }
        }
    }
}

#Preview {
    RamadanView(manager: PrayerManager())
}
