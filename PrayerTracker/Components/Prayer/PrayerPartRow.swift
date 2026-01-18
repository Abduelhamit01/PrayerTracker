//
//  PrayerPartRow.swift
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
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isCompleted ? Color.islamicGreen : Color(.systemGray3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isCompleted {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.islamicGreen)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 14)

                // Part Name
                Text(part)
                    .font(.body)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted, color: .secondary)

                Spacer()
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
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
        part: "Fardh",
        isCompleted: false,
        onTap: { print("Tapped") }
    )
    .padding()
}
