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
    
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onTap()
            }
        }) {
            HStack(spacing: 16) {
                // Enhanced Checkbox with animation
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isCompleted ? Color.islamicGreen.opacity(0.15) : Color(.systemGray6))
                        .frame(width: 32, height: 32)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isCompleted 
                                ? Color.islamicGreen 
                                : Color(.systemGray4),
                            lineWidth: isCompleted ? 2.5 : 2
                        )
                        .frame(width: 32, height: 32)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.islamicGreen)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.leading, 16)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)

                // Part Name with better styling
                VStack(alignment: .leading, spacing: 2) {
                    Text(part)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted, color: .secondary)
                    
                    if isCompleted {
                        Text("Completed")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.islamicGreen)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                Spacer()
                
                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
                    .padding(.trailing, 16)
            }
            .padding(.vertical, 14)
            .background(
                Color.clear
                    .contentShape(Rectangle())
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

#Preview("Completed") {
    VStack(spacing: 0) {
        PrayerPartRow(
            part: "Sunnah",
            isCompleted: true,
            onTap: { print("Tapped") }
        )
        
        Divider()
            .padding(.leading, 64)
        
        PrayerPartRow(
            part: "Fardh",
            isCompleted: true,
            onTap: { print("Tapped") }
        )
    }
    .background(Color(.secondarySystemBackground))
    .cornerRadius(16)
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Not Completed") {
    VStack(spacing: 0) {
        PrayerPartRow(
            part: "Sunnah",
            isCompleted: false,
            onTap: { print("Tapped") }
        )
        
        Divider()
            .padding(.leading, 64)
        
        PrayerPartRow(
            part: "Fardh",
            isCompleted: false,
            onTap: { print("Tapped") }
        )
    }
    .background(Color(.secondarySystemBackground))
    .cornerRadius(16)
    .padding()
    .background(Color(.systemGroupedBackground))
}
#Preview("Mixed States") {
    VStack(spacing: 0) {
        PrayerPartRow(
            part: "Sunnah",
            isCompleted: true,
            onTap: { print("Tapped") }
        )
        
        Divider()
            .padding(.leading, 64)
        
        PrayerPartRow(
            part: "Fardh",
            isCompleted: false,
            onTap: { print("Tapped") }
        )
        
        Divider()
            .padding(.leading, 64)
        
        PrayerPartRow(
            part: "Sunnah (After)",
            isCompleted: true,
            onTap: { print("Tapped") }
        )
    }
    .background(Color(.secondarySystemBackground))
    .cornerRadius(16)
    .padding()
    .background(Color(.systemGroupedBackground))
}

