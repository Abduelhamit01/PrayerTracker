//
//  LiquidGlassGuide.swift
//  PrayerTracker
//
//  Quick Reference Guide for Liquid Glass Implementation
//  Based on Apple Developer Documentation 2026
//

/*

# LIQUID GLASS QUICK REFERENCE

## Basic Usage

### 1. Simple Glass Effect (iOS 26+)
```swift
Text("Hello")
    .padding()
    .glassEffect() // Default: Regular glass in capsule shape
```

### 2. Custom Shape
```swift
Text("Hello")
    .padding()
    .glassEffect(.regular, in: .rect(cornerRadius: 16))
```

### 3. Interactive Glass (Responds to touch)
```swift
Button("Tap Me") {
    // Action
}
.padding()
.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
```

### 4. Tinted Glass
```swift
Text("Prominent")
    .padding()
    .glassEffect(.regular.tint(.islamicGreen.opacity(0.15)), in: .rect(cornerRadius: 16))
```

### 5. Tinted + Interactive
```swift
Button("Action") {
    // Action
}
.padding()
.glassEffect(.regular.tint(.blue.opacity(0.2)).interactive(), in: .rect(cornerRadius: 16))
```

## Container for Multiple Glass Views

When you have multiple glass elements, wrap them in GlassEffectContainer for:
- Better performance
- Morphing effects when elements get close
- Unified glass rendering

```swift
GlassEffectContainer(spacing: 20.0) {
    HStack(spacing: 20) {
        Image(systemName: "star")
            .frame(width: 60, height: 60)
            .glassEffect()
        
        Image(systemName: "heart")
            .frame(width: 60, height: 60)
            .glassEffect()
    }
}
```

The `spacing` parameter controls when glass effects merge:
- Elements within spacing distance will blend together
- Default (0) is good for batch processing

## Morphing Transitions

Create smooth morphing effects when views appear/disappear:

```swift
@State private var isExpanded = false
@Namespace private var namespace

var body: some View {
    GlassEffectContainer(spacing: 40) {
        HStack(spacing: 40) {
            Image(systemName: "pencil")
                .glassEffect()
                .glassEffectID("pencil", in: namespace)
            
            if isExpanded {
                Image(systemName: "eraser")
                    .glassEffect()
                    .glassEffectID("eraser", in: namespace)
            }
        }
    }
    
    Button("Toggle") {
        withAnimation {
            isExpanded.toggle()
        }
    }
}
```

## Button Styles with Glass

### Standard Glass Button
```swift
Button("Click Me") {
    // Action
}
.buttonStyle(.glass)
```

### Prominent Glass Button
```swift
Button("Important") {
    // Action
}
.buttonStyle(.glassProminent)
```

## Prayer Tracker App Helpers

### Our Custom Modifiers (in ContentView.swift)

#### Basic Interactive Glass
```swift
.liquidGlass(interactive: true)
```

#### Glass with Custom Shape
```swift
.liquidGlass(in: Circle(), interactive: true)
```

#### Glass with Tint
```swift
.liquidGlass(interactive: true, tint: .islamicGreen)
```

#### Prominent Glass (for hero elements)
```swift
.liquidGlassProminent(interactive: true)
```

### Our Custom Components (in LiquidGlassComponents.swift)

#### Glass Button
```swift
GlassButton("Button Text", icon: "star.fill") {
    print("Tapped")
}
```

#### Prominent Glass Button
```swift
GlassButtonProminent("Important Action", icon: "checkmark") {
    print("Tapped")
}
```

#### Glass Card
```swift
GlassCard(padding: 16) {
    VStack {
        Text("Card Title")
        Text("Card content")
    }
}
```

#### Glass Badge
```swift
GlassBadge("Completed", icon: "checkmark.circle.fill", color: .islamicGreen)
```

#### Floating Action Button
```swift
FloatingActionButton(icon: "plus") {
    print("Add something")
}
```

## Common Shapes

- `.capsule` - Pill shape (default)
- `.rect(cornerRadius: CGFloat)` - Rounded rectangle
- `.circle` - Circle
- `RoundedRectangle(cornerRadius: CGFloat)` - Custom rounded rect
- `Circle()` - Custom circle shape
- `Capsule()` - Custom capsule shape

## Best Practices

✅ DO:
- Use GlassEffectContainer for multiple glass elements
- Apply interactive glass to buttons and tappable elements
- Use consistent corner radii
- Test in both light and dark modes
- Provide iOS 25 fallback for older devices

❌ DON'T:
- Overuse glass effects (be strategic)
- Stack too many glass layers (performance)
- Use without considering backdrop content
- Forget to test with different backgrounds

## iOS Version Checking

Our app automatically handles version differences:

```swift
if #available(iOS 26.0, *) {
    // Use native .glassEffect()
    view.glassEffect(.regular, in: .rect(cornerRadius: 16))
} else {
    // Fallback to material
    view
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
}
```

## Performance Tips

1. **Batch glass effects**: Use GlassEffectContainer when possible
2. **Limit glass count**: Only apply to important elements
3. **Simple shapes**: Circles and rounded rectangles perform best
4. **Avoid nesting**: Don't put glass inside glass unnecessarily
5. **Use lazy stacks**: For long scrolling lists with glass elements

## Color Tinting Guide

Tint intensity recommendations:
- **Subtle hint**: 0.05 - 0.10 opacity
- **Noticeable**: 0.15 - 0.20 opacity
- **Prominent**: 0.25 - 0.35 opacity
- **Strong**: 0.40+ opacity (use sparingly)

Example:
```swift
.glassEffect(.regular.tint(.islamicGreen.opacity(0.15)), in: .rect(cornerRadius: 16))
```

## Animation with Glass

Glass effects animate beautifully with standard SwiftUI animations:

```swift
@State private var isHighlighted = false

Circle()
    .fill(isHighlighted ? Color.green : Color.blue)
    .frame(width: 100, height: 100)
    .glassEffect()
    .onTapGesture {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isHighlighted.toggle()
        }
    }
```

## Testing Checklist

When implementing Liquid Glass:

□ Test in light mode
□ Test in dark mode
□ Test with different backdrop colors
□ Test with different backdrop images
□ Test on iOS 26 (native glass)
□ Test on iOS 25 (fallback)
□ Test performance with multiple elements
□ Test touch/interaction responsiveness
□ Verify accessibility contrast
□ Check with VoiceOver enabled

## Resources

- Apple Developer Documentation: SwiftUI Liquid Glass
- WWDC 2026: "Building with Liquid Glass"
- Human Interface Guidelines: Materials
- Our app's DESIGN_SYSTEM.md file

*/

// This file is for reference only and should not be compiled.
// Delete or comment out to avoid build issues.
