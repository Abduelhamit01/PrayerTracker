//
//  LiquidGlassShowcase.swift
//  PrayerTracker
//
//  Visual showcase of all Liquid Glass components
//  Use this file to preview and test all modernized components
//

import SwiftUI

/// Showcase view demonstrating all Liquid Glass components
struct LiquidGlassShowcase: View {
    @State private var isExpanded = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Section 1: Buttons
                    ShowcaseSection(title: "Buttons") {
                        VStack(spacing: 12) {
                            GlassButton("Standard Glass Button", icon: "star.fill") {
                                print("Standard button tapped")
                            }
                            
                            GlassButtonProminent("Prominent Button", icon: "checkmark.circle.fill") {
                                print("Prominent button tapped")
                            }
                            
                            HStack(spacing: 12) {
                                FloatingActionButton(icon: "plus") {
                                    print("FAB tapped")
                                }
                                
                                FloatingActionButton(icon: "pencil") {
                                    print("FAB tapped")
                                }
                            }
                        }
                    }
                    
                    // Section 2: Badges
                    ShowcaseSection(title: "Badges") {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                GlassBadge("Completed", icon: "checkmark.circle.fill", color: .islamicGreen)
                                GlassBadge("Pending", icon: "clock.fill", color: .orange)
                                GlassBadge("Missed", icon: "xmark.circle.fill", color: .red)
                            }
                            
                            HStack(spacing: 12) {
                                GlassBadge("5 Prayers")
                                GlassBadge("Today", icon: "calendar")
                            }
                        }
                    }
                    
                    // Section 3: Cards
                    ShowcaseSection(title: "Cards") {
                        VStack(spacing: 12) {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "moon.stars.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(.islamicGreen)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Prayer Card")
                                                .font(.headline)
                                            Text("With icon and details")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        GlassBadge("Active", icon: "checkmark", color: .islamicGreen)
                                    }
                                }
                            }
                            
                            GlassCard(padding: 20) {
                                VStack(spacing: 16) {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.islamicGreen)
                                    
                                    Text("Statistics Card")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text("This is a larger card with more padding")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                    // Section 4: Glass Modifiers
                    ShowcaseSection(title: "Glass Modifiers") {
                        VStack(spacing: 12) {
                            Text("Liquid Glass (Capsule)")
                                .font(.headline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .liquidGlass(interactive: true)
                            
                            Text("Liquid Glass (Circle)")
                                .font(.headline)
                                .frame(width: 120, height: 120)
                                .liquidGlass(in: Circle(), interactive: true)
                            
                            Text("Liquid Glass with Tint")
                                .font(.headline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .liquidGlass(interactive: true, tint: .islamicGreen)
                            
                            Text("Prominent Glass")
                                .font(.headline)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .liquidGlassProminent(interactive: true)
                        }
                    }
                    
                    // Section 5: Interactive Elements
                    ShowcaseSection(title: "Interactive Elements") {
                        VStack(spacing: 12) {
                            Button(action: { isExpanded.toggle() }) {
                                HStack {
                                    Text("Expandable Item")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                }
                                .padding()
                            }
                            .buttonStyle(.plain)
                            
                            if isExpanded {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Expanded Content")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("This content appears with animation")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isExpanded)
                    }
                    
                    // Section 6: Dividers
                    ShowcaseSection(title: "Dividers") {
                        VStack(spacing: 20) {
                            Text("Content Above")
                            
                            GlassDivider()
                            
                            Text("Content Below")
                            
                            GlassDivider()
                            
                            Text("More Content")
                        }
                    }
                    
                    // Section 7: Color System
                    ShowcaseSection(title: "Color System") {
                        VStack(spacing: 12) {
                            ColorSwatch(color: .islamicGreen, name: "Islamic Green")
                            ColorSwatch(color: .green, name: "Success / Complete")
                            ColorSwatch(color: .yellow, name: "Warning / Partial")
                            ColorSwatch(color: .red, name: "Error / Missed")
                            ColorSwatch(color: .primary, name: "Primary Text")
                            ColorSwatch(color: .secondary, name: "Secondary Text")
                        }
                    }
                    
                    // Section 8: Typography
                    ShowcaseSection(title: "Typography") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Large Title")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Title")
                                .font(.title)
                                .fontWeight(.semibold)
                            
                            Text("Title 2")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Headline")
                                .font(.headline)
                            
                            Text("Body")
                                .font(.body)
                            
                            Text("Caption")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("Monospaced: 12:34:56")
                                .font(.system(.body, design: .monospaced))
                                .monospacedDigit()
                            
                            Text("Rounded: 123.45")
                                .font(.system(.body, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Liquid Glass Showcase")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helper Views

struct ShowcaseSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.horizontal, 4)
            
            GlassCard(padding: 20) {
                content
            }
        }
    }
}

struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.primary.opacity(0.1), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("System Color")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("Full Showcase") {
    LiquidGlassShowcase()
}

#Preview("Buttons Only") {
    VStack(spacing: 12) {
        GlassButton("Standard Button", icon: "star.fill") {
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

#Preview("Cards Only") {
    VStack(spacing: 16) {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Card Title")
                    .font(.headline)
                Text("Card description with some content")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        
        GlassCard(padding: 24) {
            VStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.islamicGreen)
                
                Text("Featured Card")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Badges Only") {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            GlassBadge("Completed", icon: "checkmark.circle.fill", color: .islamicGreen)
            GlassBadge("Pending", icon: "clock.fill", color: .orange)
        }
        
        HStack(spacing: 12) {
            GlassBadge("Missed", icon: "xmark.circle.fill", color: .red)
            GlassBadge("Today", icon: "calendar")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Dark Mode") {
    LiquidGlassShowcase()
        .preferredColorScheme(.dark)
}
