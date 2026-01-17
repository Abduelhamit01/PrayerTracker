//
//  Prayer.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 10.12.25.
//

import Foundation

struct Prayer: Identifiable {
    let id: String
    let name: String
    let parts: [String]
    let icon: String  // SF Symbol Name
}
