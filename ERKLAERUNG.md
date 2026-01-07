# Ausführliche Erklärung aller Änderungen

## 1. CustomCalendarView - Kalenderansicht mit Status-Punkten

### Was wurde erstellt?
Eine Kalenderansicht, die für jeden Tag einen farbigen Punkt anzeigt, der den Gebetsstatus visualisiert.

### Die Farblogik:
```
- Grün = Alle Fardh-Gebete erledigt
- Gelb = Teilweise Fardh erledigt (mindestens eins, aber nicht alle)
- Rot = Kein Fardh gebetet (egal wie viel Sunnah)
- Kein Punkt = Zukünftige Tage oder Tage vor Installation ohne Einträge
```

### Wie funktioniert die Status-Berechnung?

```swift
private func getStatusColor(for date: Date) -> Color {
    // 1. Zukünftige Tage bekommen keinen Punkt
    if date > Date() && !calendar.isDateInToday(date) {
        return .clear
    }

    // 2. Wir holen den Datums-Key (z.B. "07-01-2026")
    let dateKey = formatDateKey(date)

    // 3. Prüfen ob der Tag vor der App-Installation liegt
    let isBeforeInstall = date < calendar.startOfDay(for: installDate)

    // 4. Zählen wie viele Fardh/Sunnah erledigt wurden
    var fardhCompleted = 0
    var sunnahCompleted = 0

    for prayer in manager.prayers {
        for part in prayer.parts {
            // Key-Format: "07-01-2026-fajr-Fardh"
            let key = "\(dateKey)-\(prayer.id)-\(part)"
            let isCompleted = isPartCompleted(key: key)

            if part == "Fardh" {
                if isCompleted { fardhCompleted += 1 }
            } else {
                if isCompleted { sunnahCompleted += 1 }
            }
        }
    }

    // 5. Logik für Tage VOR der Installation:
    //    Wenn nichts eingetragen → kein Punkt (nicht bestrafen)
    //    Wenn etwas eingetragen → normale Logik
    if isBeforeInstall && fardhCompleted == 0 && sunnahCompleted == 0 {
        return .clear
    }

    // 6. Normale Farblogik
    if fardhCompleted == 0 { return .red }
    if fardhCompleted == totalFardh { return .green }
    return .yellow
}
```

### Warum `isPartCompleted` direkt UserDefaults liest:

```swift
private func isPartCompleted(key: String) -> Bool {
    guard let data = UserDefaults.standard.data(forKey: "completedParts"),
          let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) else {
        return false
    }
    return decoded.contains(key)
}
```

**Problem:** Der `PrayerManager` speichert erledigte Gebete mit dem Key-Format `"dd-MM-yyyy-prayerId-part"`. Aber der Manager hat nur eine Methode `isPartCompleted(prayerId:part:)` die immer das **ausgewählte Datum** verwendet.

**Lösung:** Wir lesen direkt aus UserDefaults, damit wir beliebige Daten abfragen können (nicht nur das ausgewählte Datum).

---

## 2. Swipe-Navigation mit TabView

### Das Problem mit DragGesture:
Zuerst hatte ich eine einfache `DragGesture` verwendet:

```swift
.gesture(
    DragGesture(minimumDistance: 50)
        .onEnded { value in
            if value.translation.width < 0 {
                changeMonth(by: 1)  // Nach links = nächster Monat
            } else {
                changeMonth(by: -1) // Nach rechts = vorheriger Monat
            }
        }
)
```

**Problem:** Das fühlt sich nicht flüssig an - kein visuelles Feedback während des Swipes.

### Die Lösung mit TabView + PageTabViewStyle:

```swift
TabView(selection: $currentMonthIndex) {
    ForEach(monthRange, id: \.self) { offset in
        MonthGridView(
            monthDate: getMonthDate(for: offset),
            manager: manager,
            ...
        )
        .tag(offset)
    }
}
.tabViewStyle(.page(indexDisplayMode: .never))
```

**Wie es funktioniert:**
1. `TabView` mit `.page` Style verhält sich wie ein horizontaler PageViewController
2. `selection: $currentMonthIndex` bindet den aktuellen "Tab" an eine State-Variable
3. `ForEach(-24...24)` erstellt 49 "Seiten" (24 Monate zurück, aktueller Monat, 24 Monate vor)
4. `.tag(offset)` markiert jede Seite mit ihrer Offset-Nummer
5. Wenn der User swipet, ändert sich `currentMonthIndex` automatisch

**Warum `indexDisplayMode: .never`?**
Wir wollen keine Punkte unten anzeigen (wie bei einem normalen PageControl).

---

## 3. Fixe Kalender-Höhe (6 Wochen)

### Das Problem:
Monate haben unterschiedlich viele Wochen:
- Februar 2026 startet am Sonntag → nur 4 Wochen nötig
- März 2026 startet am Sonntag → 5 Wochen nötig
- Manche Monate brauchen 6 Wochen

Wenn die Höhe variiert, "springt" die UI beim Monatswechsel.

### Die Lösung:

```swift
private func getDaysInMonth(for date: Date) -> [Int] {
    // ... normale Berechnung ...

    // WICHTIG: Immer auf 42 Zellen auffüllen (6 Wochen × 7 Tage)
    while days.count < 42 {
        days.append(0)  // 0 = leere Zelle
    }

    return days
}
```

Und dann eine fixe Höhe:
```swift
.frame(height: gridHeight)  // gridHeight = 340
```

**Warum 42 Zellen?**
- Maximum: Ein Monat kann bis zu 6 Wochen benötigen (z.B. wenn der 1. auf Samstag fällt und der Monat 31 Tage hat)
- 6 Wochen × 7 Tage = 42 Zellen
- Leere Zellen (Tag = 0) werden transparent dargestellt

---

## 4. AppInstallDate - Installationsdatum

### Warum brauchen wir das?
Wenn ein User die App am 07.01.2026 installiert, soll er nicht für alle vergangenen Tage "rote Punkte" sehen. Das wäre unfair - er hatte die App ja noch nicht!

### Die Implementierung:

```swift
class AppInstallDate {
    static let shared = AppInstallDate()  // Singleton-Pattern

    private let key = "appInstallDate"

    var installDate: Date {
        // Versuche gespeichertes Datum zu laden
        if let savedDate = UserDefaults.standard.object(forKey: key) as? Date {
            return savedDate
        } else {
            // Erstes Mal → speichere heutiges Datum
            let today = Date()
            UserDefaults.standard.set(today, forKey: key)
            return today
        }
    }

    private init() {}  // Private init verhindert weitere Instanzen
}
```

### Singleton-Pattern erklärt:
- `static let shared` = Eine einzige Instanz für die ganze App
- `private init()` = Niemand kann `AppInstallDate()` aufrufen
- Zugriff immer über `AppInstallDate.shared.installDate`

### Warum Singleton hier sinnvoll ist:
- Das Installationsdatum ändert sich nie
- Wir brauchen überall denselben Wert
- Keine Abhängigkeiten zu anderen Objekten

---

## 5. clearAllCompletions - Nur aktuellen Tag löschen

### Vorher (falsch):
```swift
func clearAllCompletions() {
    updateCompletedParts([])  // Löscht ALLES
}
```

### Nachher (richtig):
```swift
func clearAllCompletions() {
    let datePrefix = formatDateKey(selectedDate)  // z.B. "07-01-2026"
    var parts = completedParts

    // Filtere alle Keys die NICHT mit dem Datum beginnen
    parts = parts.filter { !$0.hasPrefix(datePrefix) }

    updateCompletedParts(parts)
}
```

### Wie es funktioniert:
1. `formatDateKey(selectedDate)` gibt z.B. `"07-01-2026"` zurück
2. `completedParts` enthält Keys wie `"07-01-2026-fajr-Fardh"`, `"06-01-2026-dhuhr-Sunnah"`, etc.
3. `filter { !$0.hasPrefix(datePrefix) }` behält nur Keys die **nicht** mit dem aktuellen Datum beginnen
4. Ergebnis: Nur der aktuelle Tag wird gelöscht

---

## 6. StatisticsCard - 30-Tage-Statistik

### Die Berechnung:

```swift
private func calculateStats() -> (complete: Int, partial: Int, missed: Int) {
    var complete = 0
    var partial = 0
    var missed = 0

    // Letzte 30 Tage durchgehen (inkl. heute)
    for dayOffset in 0..<30 {
        guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

        let status = getDayStatus(for: date)
        switch status {
        case .complete: complete += 1
        case .partial: partial += 1
        case .missed: missed += 1
        case .none: break  // Wird nicht gezählt
        }
    }

    return (complete, partial, missed)
}
```

### Warum ein Tuple `(complete: Int, partial: Int, missed: Int)`?
- Swift erlaubt benannte Tuple-Elemente
- Zugriff über `stats.complete`, `stats.partial`, `stats.missed`
- Keine extra Struct/Class nötig für einfache Datengruppen

---

## 7. PrayerCard - TickTick-Stil

### Struktur der Card:

```
┌─────────────────────────────────────────┐
│  🌅   Fajr                    ✓    ▼   │  ← Header (immer sichtbar)
│       2/2 erledigt                      │
├─────────────────────────────────────────┤
│  ☑️  Sunnah                             │  ← Expanded Content
│  ☑️  Fardh                    [Pflicht] │     (nur wenn aufgeklappt)
└─────────────────────────────────────────┘
```

### State-Management für Aufklappen:

```swift
@State private var isExpanded = false

Button(action: {
    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
        isExpanded.toggle()
    }
}) {
    // Header-Inhalt
}

if isExpanded {
    // Expanded Content
}
```

**Warum `@State`?**
- `isExpanded` ist lokaler UI-State
- Gehört nur zu dieser einen Card
- Braucht keine externe Speicherung

**Die Animation erklärt:**
- `.spring(response: 0.35, dampingFraction: 0.8)`
- `response` = Wie schnell die Animation reagiert (0.35 Sekunden)
- `dampingFraction` = Wie stark das "Nachschwingen" (0.8 = kaum Nachschwingen)

### Chevron-Rotation:

```swift
Image(systemName: "chevron.down")
    .rotationEffect(.degrees(isExpanded ? 180 : 0))
```

- Wenn `isExpanded = false` → 0° (zeigt nach unten)
- Wenn `isExpanded = true` → 180° (zeigt nach oben)
- Die Animation wird von `withAnimation` automatisch angewendet

---

## 8. Dark Mode Anpassungen

### Das Problem:
Im Light Mode:
- `systemBackground` = Weiß
- `systemGroupedBackground` = Hellgrau
- Kontrast: Gut sichtbar ✓

Im Dark Mode:
- `systemBackground` = Schwarz
- `systemGroupedBackground` = Sehr dunkles Grau
- Kontrast: Kaum sichtbar ✗

### Die Lösung - Environment ColorScheme:

```swift
@Environment(\.colorScheme) var colorScheme

private var cardBackground: Color {
    colorScheme == .dark
        ? Color(.secondarySystemBackground)  // Etwas heller als Hintergrund
        : Color(.systemBackground)            // Weiß
}
```

**Was ist `@Environment`?**
- SwiftUI's Dependency Injection System
- `\.colorScheme` gibt `.light` oder `.dark` zurück
- Aktualisiert automatisch wenn der User den Modus wechselt

### Schatten im Dark Mode:

```swift
.shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.04), ...)
```

- Light Mode: Sehr subtiler Schatten (4% Opacity)
- Dark Mode: Stärkerer Schatten (30% Opacity) für bessere Tiefenwirkung

---

## 9. Code-Organisation

### Vorher - Alles in ContentView:
```
ContentView.swift (200+ Zeilen)
├── ContentView
├── PrayerCard
└── PartRow
```

### Nachher - Sauber getrennt:
```
View/
├── ContentView.swift (~130 Zeilen)
│
Components/Prayer/
├── PrayerCard.swift
├── PrayerPartRow.swift
└── PrayerRow.swift (alt, wird nicht mehr verwendet)
```

### ContentView Struktur mit computed properties:

```swift
struct ContentView: View {
    var body: some View {
        TabView {
            homeTab      // Computed property
            historyTab   // Computed property
            settingsTab  // Computed property
        }
    }

    private var homeTab: some View { ... }
    private var historyTab: some View { ... }
    private var settingsTab: some View { ... }
    private var homeToolbar: some ToolbarContent { ... }
}
```

**Warum computed properties?**
- `body` bleibt übersichtlich
- Jeder Tab ist klar abgegrenzt
- Einfacher zu lesen und zu warten

### MARK-Kommentare:

```swift
// MARK: - Home Tab
private var homeTab: some View { ... }

// MARK: - Toolbar
@ToolbarContentBuilder
private var homeToolbar: some ToolbarContent { ... }
```

- Erscheinen in Xcode's Minimap und Jump Bar
- Schnelle Navigation in großen Dateien

---

## 10. Wichtige SwiftUI-Konzepte

### @StateObject vs @ObservedObject:

```swift
// In ContentView (erstellt das Objekt)
@StateObject private var manager = PrayerManager()

// In PrayerCard (bekommt das Objekt übergeben)
@ObservedObject var manager: PrayerManager
```

**Regel:**
- `@StateObject` = Wenn die View das Objekt **erstellt** (Besitzer)
- `@ObservedObject` = Wenn die View das Objekt **bekommt** (Referenz)

### ForEach mit id:

```swift
ForEach(prayer.parts, id: \.self) { part in
    PrayerPartRow(part: part, ...)
}
```

- `id: \.self` = Jedes Element identifiziert sich selbst
- Funktioniert für Strings, Ints, etc.
- Für eigene Structs: `Identifiable` protokoll oder explizite `id`

### Button vs onTapGesture:

```swift
// Button - Bessere Accessibility, Highlight-Effekte
Button(action: { ... }) {
    HStack { ... }
}
.buttonStyle(.plain)  // Entfernt Standard-Button-Styling

// onTapGesture - Einfacher, aber weniger Features
HStack { ... }
    .onTapGesture { ... }
```

---

## Zusammenfassung der Datei-Änderungen

| Datei | Änderung |
|-------|----------|
| `CustomCalendarView.swift` | Neu erstellt - Kalender mit Status-Punkten und Swipe |
| `CalendarHistory.swift` | StatisticsCard hinzugefügt |
| `WeekView.swift` | Status-Punkte + Dark Mode Farben |
| `ContentView.swift` | PrayerCard-Stil + Code-Organisation |
| `PrayerCard.swift` | Neu erstellt - Ausgelagerte Card-Komponente |
| `PrayerPartRow.swift` | TickTick-Stil Checkbox |
| `PrayerManager.swift` | clearAllCompletions nur für aktuellen Tag |
| `AppInstallDate.swift` | Neu erstellt - Speichert Installationsdatum |
