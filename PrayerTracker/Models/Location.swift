//
//  Location.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 28.01.26.
//

import Foundation

// MARK: - Country

struct Country: Codable, Identifiable, Hashable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "countryID"
        case name = "countryName"
    }
}

// MARK: - State (Bundesland)

struct DiyanetState: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let countryID: Int

    enum CodingKeys: String, CodingKey {
        case id = "stateID"
        case name = "stateName"
        case countryID
    }
}

// MARK: - City

struct City: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let stateID: Int

    enum CodingKeys: String, CodingKey {
        case id = "cityID"
        case name = "cityName"
        case stateID
    }
}

// MARK: - API Responses

struct CountriesResponse: Codable {
    let data: [Country]
}

struct StatesResponse: Codable {
    let data: [DiyanetState]
}

struct CitiesResponse: Codable {
    let data: [City]
}
