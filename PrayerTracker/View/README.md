# 🕌 Prayer Tracker - Modern Liquid Glass Edition

A beautiful, modern iOS prayer tracking app built with **SwiftUI** and **Apple's 2026 Liquid Glass design system**.

![iOS](https://img.shields.io/badge/iOS-26.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green.svg)

## ✨ Features

### 🎨 Modern Liquid Glass Design
- **iOS 26+ Native Glass Effects**: Utilizes Apple's latest `.glassEffect()` API
- **Interactive Materials**: Glass elements respond to touch and pointer interactions
- **Smooth Animations**: Spring-based animations with perfect timing curves
- **Dark Mode Support**: Beautiful appearance in both light and dark modes
- **Backward Compatible**: Graceful fallback to materials on iOS 25

### 📿 Prayer Tracking
- **5 Daily Prayers**: Track Fajr, Dhuhr, Asr, Maghrib, and Isha
- **Prayer Parts**: Separate tracking for Sunnah and Fardh prayers
- **Real-time Countdown**: See time remaining until next prayer
- **Prayer Times API**: Automatic prayer times based on location
- **Completion States**: Visual feedback for completed prayers

### 📅 Calendar Features
- **Week View**: Swipe through weeks with beautiful day cards
- **Status Indicators**: Color-coded dots showing daily completion
  - 🟢 Green: All Fardh prayers completed
  - 🟡 Yellow: Some prayers missed
  - 🔴 Red: No Fardh prayers completed
- **Smooth Navigation**: Matched geometry transitions

### 🌙 Ramadan Mode
- Special Ramadan tracking features
- Suhoor and Iftar times
- Optional feature that can be enabled

### 📊 History & Analytics
- Calendar history view
- Track your prayer consistency over time
- Visual statistics

## 🎯 Modern Design Highlights

### Visual Components

#### 1. **Prayer Cards**
- Large, prominent icons (52x52 pt)
- Smooth expand/collapse animations
- Completion state indicators
- Prayer time display with icons
- Enhanced shadows and borders

#### 2. **Next Prayer Countdown**
- Hero card design with gradient background
- Large countdown timer (52pt bold)
- Prayer-specific icons (sunrise, sun, moon)
- Islamic green accent colors
- "Until [time]" display for clarity

#### 3. **Week Calendar**
- Glass pill month indicator
- Enhanced day buttons with gradients
- Status dots with glow effects
- Selected state animations
- Today indicator with border

#### 4. **Prayer Part Rows**
- Enhanced checkboxes (32x32 pt)
- Completion animations
- "Completed" status label
- Press feedback animations
- Subtle chevron indicators

### Reusable Components

All modern components are in `LiquidGlassComponents.swift`:

- `GlassButton` - Standard glass button
- `GlassButtonProminent` - Prominent button with gradient
- `GlassCard` - Reusable card container
- `GlassBadge` - Status indicators
- `GlassDivider` - Gradient dividers
- `FloatingActionButton` - Circular FAB

### Custom Modifiers

Powerful view modifiers in `ContentView.swift`:

```swift
// Basic glass effect
.liquidGlass(interactive: true, tint: .islamicGreen)

// Custom shape
.liquidGlass(in: Circle(), interactive: true)

// Prominent style
.liquidGlassProminent(interactive: true)
```

## 📱 Requirements

- **iOS 26.0+** (recommended) or iOS 25.0+ (with fallback)
- **Xcode 16.0+**
- **Swift 6.0+**

## 🏗️ Project Structure

```
PrayerTracker/
├── Models/
│   └── PrayerTime.swift          # Data models for API responses
│
├── Views/
│   ├── ContentView.swift         # Main view with Liquid Glass modifiers
│   ├── PrayerCard.swift          # Enhanced prayer card component
│   ├── PrayerPartRow.swift       # Prayer part checkbox row
│   ├── NextPrayerCountdownView.swift  # Countdown timer card
│   ├── WeekView.swift            # Week calendar view
│   └── LiquidGlassShowcase.swift # Component showcase
│
├── Components/
│   └── LiquidGlassComponents.swift  # Reusable glass components
│
├── Managers/
│   ├── PrayerManager.swift       # Prayer state management
│   ├── PrayerTimeManager.swift   # API integration
│   └── RamadanManager.swift      # Ramadan features
│
└── Documentation/
    ├── DESIGN_SYSTEM.md          # Complete design system docs
    ├── LiquidGlassGuide.swift    # Quick reference guide
    └── MODERNIZATION_SUMMARY.md  # Summary of changes
```

## 🎨 Design System

### Colors

```swift
Color.islamicGreen  // #00A86B - Primary brand color
.primary            // Text
.secondary          // Supporting text
.green              // Success states
.yellow             // Warning states
.red                // Error states
```

### Typography

- **Bold**: Headlines, timers, day numbers
- **Semibold**: Buttons, labels, subheadlines
- **Medium**: Body text, times
- **Rounded**: Numbers, dates, countdown

### Spacing

- **XS**: 4-6pt
- **S**: 8-10pt
- **M**: 12-16pt
- **L**: 20-24pt
- **XL**: 28-32pt

### Corner Radius

- **Small**: 8-10pt (badges)
- **Medium**: 12-14pt (buttons, cells)
- **Large**: 16pt (cards)
- **XL**: 20pt (hero elements)

### Animations

```swift
// Standard spring
.spring(response: 0.35, dampingFraction: 0.75)

// Smooth spring
.spring(response: 0.4, dampingFraction: 0.75)

// Quick snap
.snappy
```

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd PrayerTracker
```

### 2. Open in Xcode

```bash
open PrayerTracker.xcodeproj
```

### 3. Build and Run

- Select your target device (iOS 26+ simulator recommended)
- Press `Cmd + R` to build and run
- Grant location permissions for prayer times

### 4. Explore Components

Open `LiquidGlassShowcase.swift` in Xcode Previews to see all components.

## 📚 Documentation

- **[DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)** - Complete design system documentation
- **[LiquidGlassGuide.swift](LiquidGlassGuide.swift)** - Quick reference with code examples
- **[MODERNIZATION_SUMMARY.md](MODERNIZATION_SUMMARY.md)** - Summary of all updates

## 🎯 Key Features Implementation

### Prayer Times API Integration

The app uses a prayer times API to fetch accurate prayer times based on user location:

```swift
@ObservedObject var prayerTimeManager = PrayerTimeManager()

// Fetch today's times
await prayerTimeManager.fetchTodaysTimes()

// Access prayer times
if let times = prayerTimeManager.todaysTimes {
    print("Fajr: \(times.fajr)")
    print("Dhuhr: \(times.dhuhr)")
    // ...
}
```

### State Management

Prayer completion state is managed through `PrayerManager`:

```swift
@StateObject private var manager = PrayerManager()

// Toggle prayer part completion
manager.togglePartCompletion(prayerId: "fajr", part: "Sunnah")

// Check if all parts are completed
let isComplete = manager.isAllCompleted(prayer: prayer)

// Complete all prayers
manager.completeAllPrayers()
```

### Location-Based Prayer Times

Set user's location to get accurate prayer times:

```swift
prayerTimeManager.selectedCity = City(
    id: 1,
    name: "Istanbul",
    displayName: "Istanbul"
)
```

## 🎨 Customization

### Change Primary Color

Update `Color.islamicGreen` throughout the app:

```swift
extension Color {
    static let islamicGreen = Color(red: 0.0, green: 0.66, blue: 0.42)
}
```

### Adjust Animations

Modify spring parameters for different feels:

```swift
// More bouncy
.spring(response: 0.3, dampingFraction: 0.6)

// Less bouncy
.spring(response: 0.4, dampingFraction: 0.85)
```

### Add New Glass Components

Use the custom modifiers:

```swift
MyCustomView()
    .liquidGlass(
        in: RoundedRectangle(cornerRadius: 20),
        interactive: true,
        tint: .blue
    )
```

## 🧪 Testing

### Preview Components

All major components have SwiftUI previews:

```swift
#Preview {
    PrayerCard(
        prayer: Prayer.sample,
        manager: PrayerManager(),
        prayerTimeManager: PrayerTimeManager(),
        onPartTap: { _ in }
    )
}
```

### Test Different States

Use the showcase view to test all states:

```swift
#Preview("Dark Mode") {
    LiquidGlassShowcase()
        .preferredColorScheme(.dark)
}
```

## 🎭 iOS Version Support

### iOS 26+ (Recommended)
- Native `.glassEffect()` API
- Interactive glass materials
- `GlassEffectContainer` for performance
- Full morphing and blending

### iOS 25 (Fallback)
- `.ultraThinMaterial` backgrounds
- Manual borders and strokes
- Similar visual appearance
- All functionality maintained

## 🔮 Future Enhancements

- [ ] Haptic feedback for interactions
- [ ] Advanced morphing transitions
- [ ] Widget with Liquid Glass
- [ ] Apple Watch companion app
- [ ] iPad-optimized layouts
- [ ] Siri shortcuts integration
- [ ] HealthKit integration
- [ ] CloudKit sync across devices

## 📱 Screenshots

*Add screenshots of your app here*

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

*Add your license here*

## 🙏 Acknowledgments

- Apple's Human Interface Guidelines 2026
- Liquid Glass Design Language
- Islamic prayer tracking community
- Prayer times API provider

## 📞 Support

For questions or issues, please open an issue on GitHub.

---

**Built with ❤️ using SwiftUI and Apple's latest design guidelines**

**Last Updated**: February 3, 2026
