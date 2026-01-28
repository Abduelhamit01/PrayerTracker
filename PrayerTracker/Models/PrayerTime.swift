//
//  PrayerTime.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 28.01.26.
//

import Foundation

// MARK: - Prayer Times Model

struct PrayerTimes: Codable {
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
    let gregorianDate: String
    let hijriDate: String

    enum CodingKeys: String, CodingKey {
        case fajr = "fajr"
        case sunrise = "sunrise"
        case dhuhr = "dhuhr"
        case asr = "asr"
        case maghrib = "maghrib"
        case isha = "isha"
        case gregorianDate = "gregorianDateShort"
        case hijriDate = "hijriDateShort"
    }

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

struct PrayerTimesResponse: Codable {
    let data: PrayerTimes?
}

// MARK: - Auth Response

struct AuthResponse: Codable {
    let data: AuthData?
}

struct AuthData: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
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
            gregorianDate: "28.01.2026",
            hijriDate: "09.07.1447"
        )
    }
}
