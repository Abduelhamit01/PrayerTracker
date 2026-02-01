//
//  PrayerTime.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 28.01.26.
//

import Foundation

// MARK: - Prayer Times Model
// API Response Format:
// {
//   "fajr": "06:19", "sunrise": "08:07", "dhuhr": "12:50",
//   "asr": "14:58", "maghrib": "17:24", "isha": "18:59",
//   "hijriDateShort": "10.8.1447", "gregorianDateShort": "29.01.2026",
//   "shapeMoonUrl": "https://...", "qiblaTime": "08:57"
// }

struct PrayerTimes: Codable, Equatable {
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
    let gregorianDateShort: String
    let hijriDateShort: String
    let shapeMoonUrl: String?
    let qiblaTime: String?

    /// Gibt die Zeit für ein bestimmtes Gebet zurück
    func time(for prayerId: String) -> String? {
        switch prayerId {
        case "fajr": return fajr
        case "dhuhr": return dhuhr
        case "asr": return asr
        case "maghrib": return maghrib
        case "isha": return isha
        default: return nil
        }
    }
}

// MARK: - API Response
// Die API gibt ein Array zurück: { "data": [...], "success": true }

struct PrayerTimesResponse: Codable {
    let data: [PrayerTimes]
    let success: Bool
}

// MARK: - Auth Response
// API Response: { "data": { "accessToken": "...", "refreshToken": "..." }, "success": true, "message": null }

struct AuthResponse: Codable {
    let data: AuthData?
    let success: Bool
    let message: String?
}

struct AuthData: Codable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Placeholder Data

extension PrayerTimes {
    /// Platzhalter-Daten für die Entwicklung (ohne API-Zugang)
    static var placeholder: PrayerTimes {
        PrayerTimes(
            fajr: "06:44",
            sunrise: "08:13",
            dhuhr: "13:22",
            asr: "15:57",
            maghrib: "18:21",
            isha: "19:44",
            gregorianDateShort: "29.01.2026",
            hijriDateShort: "10.08.1447",
            shapeMoonUrl: nil,
            qiblaTime: nil
        )
    }
}
