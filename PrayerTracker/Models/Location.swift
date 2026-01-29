//
//  Location.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 28.01.26.
//

import Foundation

// MARK: - Country
// API Response: {"id": 13, "code": "GERMANY", "name": "ALMANYA"}

struct Country: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let code: String?

    // Für manuelle Erstellung (Demo-Daten)
    init(id: Int, name: String, code: String? = nil) {
        self.id = id
        self.name = name
        self.code = code
    }

    /// Gibt den Namen in der passenden Sprache zurück (Türkisch = name, sonst = code)
    var displayName: String {
        if Locale.isTurkish {
            return name.capitalized
        }
        return (code ?? name).capitalized
    }
}

// MARK: - State (Bundesland)
// API Response: {"id": 859, "code": "NORTH RHEIN WESTPHALIA", "name": "NORDRHEIN-WESTFALEN"}
// Hinweis: API gibt kein countryId zurück

struct DiyanetState: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let code: String?
    var countryID: Int? = nil // Nicht von API, wird lokal gesetzt

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case code
    }

    // Für Codable: Standard-Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        countryID = nil
    }

    // Für manuelle Erstellung (Demo-Daten)
    init(id: Int, name: String, countryID: Int? = nil, code: String? = nil) {
        self.id = id
        self.name = name
        self.countryID = countryID
        self.code = code
    }

    /// Gibt den Namen in der passenden Sprache zurück (Türkisch = name, sonst = code)
    var displayName: String {
        if Locale.isTurkish {
            return name.capitalized
        }
        return (code ?? name).capitalized
    }
}

// MARK: - City
// API Response: {"id": 11019, "code": "KOLN", "name": "KOLN"}
// Hinweis: API gibt kein stateId zurück

struct City: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let code: String?
    var stateID: Int? = nil // Nicht von API, wird lokal gesetzt

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case code
    }

    // Für Codable: Standard-Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        stateID = nil
    }

    // Für manuelle Erstellung (Demo-Daten)
    init(id: Int, name: String, stateID: Int? = nil, code: String? = nil) {
        self.id = id
        self.name = name
        self.stateID = stateID
        self.code = code
    }

    /// Gibt den Namen in der passenden Sprache zurück (Türkisch = name, sonst = code)
    var displayName: String {
        if Locale.isTurkish {
            return name.capitalized
        }
        return (code ?? name).capitalized
    }
}

// MARK: - Locale Helper

extension Locale {
    /// Prüft ob die aktuelle Sprache Türkisch ist
    static var isTurkish: Bool {
        Locale.current.language.languageCode?.identifier == "tr"
    }
}

// MARK: - API Responses
// Alle API Responses haben: data, success, message

struct CountriesResponse: Codable {
    let data: [Country]
    let success: Bool
    let message: String?
}

struct StatesResponse: Codable {
    let data: [DiyanetState]
    let success: Bool
    let message: String?
}

struct CitiesResponse: Codable {
    let data: [City]
    let success: Bool
    let message: String?
}
