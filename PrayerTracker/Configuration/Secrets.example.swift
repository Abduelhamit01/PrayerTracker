//
//  Secrets.example.swift
//  PrayerTracker
//
//  Dies ist eine Vorlage für die Secrets.swift Datei.
//
//  ANLEITUNG:
//  1. Kopiere diese Datei und benenne sie in "Secrets.swift" um
//  2. Trage deine echten API-Daten und Zugangsdaten ein
//  3. Füge Secrets.swift zum Xcode-Projekt hinzu
//
//  Created by Abdülhamit Oral on 28.01.26.
//

import Foundation

enum Secrets {
    // MARK: - API Configuration
    // Beantrage Zugang bei der entsprechenden Behörde

    static let diyanetBaseURL = "https://YOUR_API_BASE_URL"
    static let diyanetUsername = "YOUR_USERNAME"
    static let diyanetPassword = "YOUR_PASSWORD"

    // MARK: - API Endpoints
    static let authEndpoint = "/auth/endpoint"
    static let countriesEndpoint = "/countries/endpoint"
    static let statesEndpoint = "/states/endpoint"
    static let citiesEndpoint = "/cities/endpoint"
    static let dailyTimesEndpoint = "/times/endpoint"
}
