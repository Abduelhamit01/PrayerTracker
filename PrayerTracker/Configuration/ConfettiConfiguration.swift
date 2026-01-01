//
//  ConfettiConfiguration.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 16.12.25.
//

import SwiftUI
import ConfettiSwiftUI

struct ConfettiConfiguration {
    static let prayerEmojis: [ConfettiType] = [
        .text("🤲"), .text("🕌"), .text("🌟"),
        .text("✨"), .text("📿"), .text("🥳")
    ]
    static let confettiSize: CGFloat = 15
    static let rainHeight: CGFloat = 1000
    static let radius: CGFloat = 400
    static let repetitionInterval: Double = 0.3
}

