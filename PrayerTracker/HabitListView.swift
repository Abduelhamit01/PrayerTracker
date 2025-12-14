//
//  HabitListView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 13.12.25.
//

import SwiftUI

struct HabitListView: View {
    var body: some View {
        VStack(alignment: .leading){
            
            VStack(alignment: .trailing) {
                Text("13.12.2025")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.cyan)
                
                Text("🔥 1 day Streak")
                    .font(.title3)
            }
            
            Button(
                action: {
                
            }, label: {
                HStack {
                    Text("🤲🏼")
                        .font(Font.system(size: 60))
                    VStack{
                        Text("Habit Title")
                            .foregroundStyle(.orange)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Habit Description")
                            .foregroundStyle(Color(.label))
                            .font(.subheadline)
                        
                        Text("1 day streak")
                            .foregroundStyle(Color(.label))
                            .font(.subheadline)
                    }
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            )
            Button(action: {}, label: {
                Image(systemName: "plus.circle.fill")
            })
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

#Preview {
    HabitListView()
}
