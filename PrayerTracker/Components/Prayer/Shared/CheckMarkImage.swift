//
//  File.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 16.12.25.
//

import SwiftUI

struct CheckMarkImage: View {
    let isCompleted: Bool
    let mycolor = Color("IslamicGreen")

    
    var body: some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(isCompleted ? .islamicGreen : .gray)
            .font(.system(size: 30))
    }
}

#Preview("Completed") {
    CheckMarkImage(isCompleted: true)
}

#Preview("Not Completed") {
    CheckMarkImage(isCompleted: false)
}
