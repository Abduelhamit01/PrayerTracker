//
//  LiquidGlassComponents.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 03.02.26.
//

import SwiftUI

// MARK: - Glass Button Styles

/// Modern glass button for primary actions
struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.primary.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Prominent glass button with Islamic green accent
struct GlassButtonProminent: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color.islamicGreen,
                        Color.islamicGreen.opacity(0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .islamicGreen.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Glass Card Container

/// A reusable glass card container
struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
            )
    }
}

// MARK: - Glass Badge

/// Small glass badge for status indicators
struct GlassBadge: View {
    let text: String
    let icon: String?
    let color: Color
    
    init(_ text: String, icon: String? = nil, color: Color = .islamicGreen) {
        self.text = text
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
            }
            
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Glass Divider

/// A subtle glass divider
struct GlassDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        .primary.opacity(0.1),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
}

// MARK: - Floating Action Button with Glass Effect

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            Color.islamicGreen,
                            Color.islamicGreen.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .islamicGreen.opacity(0.4), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview Helpers

#Preview("Glass Buttons") {
    VStack(spacing: 20) {
        GlassButton("Regular Button", icon: "star.fill") {
            print("Tapped")
        }
        
        GlassButtonProminent("Prominent Button", icon: "checkmark") {
            print("Tapped")
        }
        
        FloatingActionButton(icon: "plus") {
            print("Tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Glass Components") {
    VStack(spacing: 20) {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Glass Card")
                    .font(.headline)
                
                Text("This is a reusable glass card component with modern styling.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        
        HStack(spacing: 12) {
            GlassBadge("Completed", icon: "checkmark.circle.fill")
            GlassBadge("Pending", icon: "clock.fill", color: .orange)
            GlassBadge("Missed", icon: "xmark.circle.fill", color: .red)
        }
        
        GlassDivider()
            .padding(.vertical)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
