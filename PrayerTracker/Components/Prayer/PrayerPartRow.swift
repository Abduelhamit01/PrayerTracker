//
//  SecondList.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 16.12.25.
//

import SwiftUI

struct PrayerPartRow: View {
    let part: String
    let isCompleted: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text("📿")
                .font(.system(size: 40))
            VStack(alignment: .leading, spacing: 2) {
                Text(part)
                    .font(.body)
                    .fontWeight(.medium)
            }
            Spacer()
            CheckMarkImage(isCompleted: isCompleted)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview("Completed") {
    PrayerPartRow(
        part: "Sunnah",
        isCompleted: true,
        onTap: { print("Tapped") }
    )
    .padding()
}

#Preview("Not Completed") {
    PrayerPartRow(
        part: "Dhuhr (Mittagsgebet)",
        isCompleted: false,
        onTap: { print("Tapped") }
    )
    .padding()
}
