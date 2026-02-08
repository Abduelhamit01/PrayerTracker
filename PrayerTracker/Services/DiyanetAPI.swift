//
//  DiyanetAPI.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 28.01.26.
//

import Foundation

// MARK: - Diyanet API Client

class DiyanetAPI {
    static let shared = DiyanetAPI()
    
    // MARK: - Configuration
    private let baseURL = Secrets.diyanetBaseURL
    private let username = Secrets.diyanetUsername
    private let password = Secrets.diyanetPassword
    
    // MARK: - Token Management
    private var accessToken: String?
    private var refreshToken: String?
    private var tokenExpiry: Date?
    
    private init() {}
    
    // MARK: - Authentication
    
    /// Prüft ob Credentials konfiguriert sind
    var hasCredentials: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    /// Prüft ob Token gültig ist
    private var isTokenValid: Bool {
        guard let expiry = tokenExpiry else { return false }
        return Date() < expiry.addingTimeInterval(-60) // 1 Minute Puffer
    }
    
    /// Login und Token erhalten
    func login() async throws {
        guard hasCredentials else {
            throw DiyanetAPIError.noCredentials
        }
        
        let url = URL(string: "\(baseURL)\(Secrets.authEndpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("PrayerTracker/1.0 iOS", forHTTPHeaderField: "User-Agent")
        
        // API erwartet "Email" und "Password"
        let body = ["Email": username, "Password": password]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DiyanetAPIError.authenticationFailed
        }
        
        if httpResponse.statusCode != 200 {
            throw DiyanetAPIError.authenticationFailed
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        guard let authData = authResponse.data else {
            throw DiyanetAPIError.invalidResponse
        }
        
        self.accessToken = authData.accessToken
        self.refreshToken = authData.refreshToken
        // Token ist 45 Minuten gültig (laut API Dokumentation)
        self.tokenExpiry = Date().addingTimeInterval(45 * 60)
    }
    
    /// Stellt sicher, dass ein gültiger Token vorhanden ist
    private func ensureValidToken() async throws {
        if !isTokenValid {
            try await login()
        }
    }
    
    // MARK: - API Requests
    
    /// Führt einen authentifizierten GET-Request durch
    private func authenticatedRequest<T: Decodable>(endpoint: String) async throws -> T {
        try await ensureValidToken()
        
        guard let token = accessToken else {
            throw DiyanetAPIError.noToken
        }
        
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("PrayerTracker/1.0 iOS", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DiyanetAPIError.requestFailed
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw error
        }
        
    }
    
    // MARK: - Public API Methods
    
    /// Alle Länder abrufen
    func getCountries() async throws -> [Country] {
        let response: CountriesResponse = try await authenticatedRequest(endpoint: Secrets.countriesEndpoint)
        return response.data
    }
    
    /// Bundesländer für ein Land abrufen
    func getStates(countryID: Int) async throws -> [DiyanetState] {
        // API verwendet Pfad-Parameter: /api/Place/States/{countryId}
        let response: StatesResponse = try await authenticatedRequest(endpoint: "\(Secrets.statesEndpoint)/\(countryID)")
        return response.data
    }
    
    /// Städte für ein Bundesland abrufen
    func getCities(stateID: Int) async throws -> [City] {
        // API verwendet Pfad-Parameter: /api/Place/Cities/{stateId}
        let response: CitiesResponse = try await authenticatedRequest(endpoint: "\(Secrets.citiesEndpoint)/\(stateID)")
        return response.data
    }
    
    /// Tägliche Gebetszeiten für eine Stadt abrufen
    func getDailyPrayerTimes(cityID: Int) async throws -> PrayerTimes {
        // API verwendet Pfad-Parameter: /api/PrayerTime/Daily/{cityId}
        // Response ist ein Array mit einem Element
        let response: PrayerTimesResponse = try await authenticatedRequest(endpoint: "\(Secrets.dailyTimesEndpoint)/\(cityID)")
        guard let times = response.data.first else {
            throw DiyanetAPIError.invalidResponse
        }
        return times
    }
    
    func getWeeklyPrayerTime(cityID: Int) async throws -> [PrayerTimes] {
        let response: PrayerTimesResponse = try await authenticatedRequest(endpoint: "\(Secrets.weeklyTimesEndpoint)/\(cityID)")
        return response.data
    }
}

// MARK: - API Errors

enum DiyanetAPIError: LocalizedError {
    case noCredentials
    case authenticationFailed
    case noToken
    case requestFailed
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .noCredentials:
            return "API-Zugangsdaten nicht konfiguriert. Bitte API-Zugang bei Diyanet beantragen."
        case .authenticationFailed:
            return "Authentifizierung fehlgeschlagen. Bitte Zugangsdaten prüfen."
        case .noToken:
            return "Kein gültiger Token vorhanden."
        case .requestFailed:
            return "API-Anfrage fehlgeschlagen."
        case .invalidResponse:
            return "Ungültige API-Antwort."
        }
    }
}
