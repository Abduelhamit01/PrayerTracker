//
//  PrayerTimeManager.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 28.01.26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Prayer Time Manager

class PrayerTimeManager: ObservableObject {
    // MARK: - Published Properties
    @Published var todaysTimes: PrayerTimes?
    @Published var selectedCountry: Country?
    @Published var selectedState: DiyanetState?
    @Published var selectedCity: City?
    @Published var countries: [Country] = []
    @Published var states: [DiyanetState] = []
    @Published var cities: [City] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var usePlaceholder = true // Nutzt Platzhalter wenn true

    // MARK: - Storage Keys
    private let cityIDKey = "selectedCityID"
    private let cityNameKey = "selectedCityName"
    private let stateIDKey = "selectedStateID"
    private let stateNameKey = "selectedStateName"
    private let countryIDKey = "selectedCountryID"
    private let countryNameKey = "selectedCountryName"
    private let cachedTimesKey = "cachedPrayerTimes"
    private let cachedDateKey = "cachedPrayerTimesDate"

    // MARK: - DateFormatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    // MARK: - Initialization

    init() {
        loadSavedLocation()
        loadCachedTimes()
    }

    // MARK: - Public Methods

    /// Lädt die heutigen Gebetszeiten
    func fetchTodaysTimes() async {
        // Wenn Platzhalter aktiviert ist (keine API-Credentials)
        if usePlaceholder || !DiyanetAPI.shared.hasCredentials {
            await MainActor.run {
                self.todaysTimes = .placeholder
            }
            return
        }

        guard let cityID = selectedCity?.id else {
            await MainActor.run {
                self.error = "Bitte wähle einen Standort in den Einstellungen aus."
            }
            return
        }

        // Prüfe ob gecachte Zeiten noch aktuell sind
        if let cached = todaysTimes, isCacheValid() {
            return // Cache ist noch aktuell
        }

        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }

        do {
            let times = try await DiyanetAPI.shared.getDailyPrayerTimes(cityID: cityID)
            await MainActor.run {
                self.todaysTimes = times
                self.isLoading = false
                self.cacheTimes(times)
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
                // Bei Fehler: Platzhalter nutzen
                self.todaysTimes = .placeholder
            }
        }
    }

    /// Lädt alle Länder
    func fetchCountries() async {
        guard DiyanetAPI.shared.hasCredentials else {
            await MainActor.run {
                // Demo-Daten für Entwicklung
                self.countries = [
                    Country(id: 2, name: "Deutschland"),
                    Country(id: 1, name: "Türkei"),
                    Country(id: 3, name: "Österreich"),
                    Country(id: 4, name: "Schweiz")
                ]
            }
            return
        }

        await MainActor.run {
            self.isLoading = true
        }

        do {
            let countries = try await DiyanetAPI.shared.getCountries()
            await MainActor.run {
                self.countries = countries.sorted { $0.name < $1.name }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// Lädt Bundesländer für ein Land
    func fetchStates(for country: Country) async {
        await MainActor.run {
            self.selectedCountry = country
            self.states = []
            self.cities = []
            self.selectedState = nil
            self.selectedCity = nil
        }

        guard DiyanetAPI.shared.hasCredentials else {
            await MainActor.run {
                // Demo-Daten für Entwicklung
                if country.id == 2 { // Deutschland
                    self.states = [
                        DiyanetState(id: 1, name: "Nordrhein-Westfalen", countryID: 2),
                        DiyanetState(id: 2, name: "Bayern", countryID: 2),
                        DiyanetState(id: 3, name: "Baden-Württemberg", countryID: 2),
                        DiyanetState(id: 4, name: "Berlin", countryID: 2),
                        DiyanetState(id: 5, name: "Hamburg", countryID: 2)
                    ]
                }
            }
            return
        }

        await MainActor.run {
            self.isLoading = true
        }

        do {
            let states = try await DiyanetAPI.shared.getStates(countryID: country.id)
            await MainActor.run {
                self.states = states.sorted { $0.name < $1.name }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// Lädt Städte für ein Bundesland
    func fetchCities(for state: DiyanetState) async {
        await MainActor.run {
            self.selectedState = state
            self.cities = []
            self.selectedCity = nil
        }

        guard DiyanetAPI.shared.hasCredentials else {
            await MainActor.run {
                // Demo-Daten für Entwicklung
                if state.id == 1 { // NRW
                    self.cities = [
                        City(id: 9179, name: "Köln", stateID: 1),
                        City(id: 9180, name: "Düsseldorf", stateID: 1),
                        City(id: 9181, name: "Dortmund", stateID: 1),
                        City(id: 9182, name: "Essen", stateID: 1),
                        City(id: 9183, name: "Duisburg", stateID: 1)
                    ]
                }
            }
            return
        }

        await MainActor.run {
            self.isLoading = true
        }

        do {
            let cities = try await DiyanetAPI.shared.getCities(stateID: state.id)
            await MainActor.run {
                self.cities = cities.sorted { $0.name < $1.name }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// Setzt den ausgewählten Standort
    func setLocation(city: City) {
        selectedCity = city
        saveLocation()
        Task {
            await fetchTodaysTimes()
        }
    }

    /// Gibt die Zeit für ein Gebet zurück
    func time(for prayerId: String) -> String? {
        todaysTimes?.time(for: prayerId)
    }

    // MARK: - Private Methods

    /// Lädt gespeicherten Standort
    private func loadSavedLocation() {
        let defaults = UserDefaults.standard

        if let cityID = defaults.object(forKey: cityIDKey) as? Int,
           let cityName = defaults.string(forKey: cityNameKey),
           let stateID = defaults.object(forKey: stateIDKey) as? Int {
            selectedCity = City(id: cityID, name: cityName, stateID: stateID)
        }

        if let stateID = defaults.object(forKey: stateIDKey) as? Int,
           let stateName = defaults.string(forKey: stateNameKey),
           let countryID = defaults.object(forKey: countryIDKey) as? Int {
            selectedState = DiyanetState(id: stateID, name: stateName, countryID: countryID)
        }

        if let countryID = defaults.object(forKey: countryIDKey) as? Int,
           let countryName = defaults.string(forKey: countryNameKey) {
            selectedCountry = Country(id: countryID, name: countryName)
        }
    }

    /// Speichert den ausgewählten Standort
    private func saveLocation() {
        let defaults = UserDefaults.standard

        if let city = selectedCity {
            defaults.set(city.id, forKey: cityIDKey)
            defaults.set(city.name, forKey: cityNameKey)
            defaults.set(city.stateID, forKey: stateIDKey)
        }

        if let state = selectedState {
            defaults.set(state.id, forKey: stateIDKey)
            defaults.set(state.name, forKey: stateNameKey)
            defaults.set(state.countryID, forKey: countryIDKey)
        }

        if let country = selectedCountry {
            defaults.set(country.id, forKey: countryIDKey)
            defaults.set(country.name, forKey: countryNameKey)
        }
    }

    /// Lädt gecachte Gebetszeiten
    private func loadCachedTimes() {
        let defaults = UserDefaults.standard

        guard let data = defaults.data(forKey: cachedTimesKey),
              isCacheValid() else {
            // Kein Cache oder abgelaufen -> Platzhalter nutzen
            todaysTimes = .placeholder
            return
        }

        if let times = try? JSONDecoder().decode(PrayerTimes.self, from: data) {
            todaysTimes = times
        } else {
            todaysTimes = .placeholder
        }
    }

    /// Speichert Gebetszeiten im Cache
    private func cacheTimes(_ times: PrayerTimes) {
        let defaults = UserDefaults.standard

        if let data = try? JSONEncoder().encode(times) {
            defaults.set(data, forKey: cachedTimesKey)
            defaults.set(dateFormatter.string(from: Date()), forKey: cachedDateKey)
        }
    }

    /// Prüft ob der Cache noch gültig ist (heute)
    private func isCacheValid() -> Bool {
        guard let cachedDate = UserDefaults.standard.string(forKey: cachedDateKey) else {
            return false
        }
        return cachedDate == dateFormatter.string(from: Date())
    }
}
