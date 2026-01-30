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
    @Published var usePlaceholder = false // Nutzt Platzhalter wenn true

    // MARK: - Notification
    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled")

    // MARK: - Storage Keys
    private let cityIDKey = "selectedCityID"
    private let cityNameKey = "selectedCityName"
    private let cityCodeKey = "selectedCityCode"
    private let stateIDKey = "selectedStateID"
    private let stateNameKey = "selectedStateName"
    private let stateCodeKey = "selectedStateCode"
    private let countryIDKey = "selectedCountryID"
    private let countryNameKey = "selectedCountryName"
    private let countryCodeKey = "selectedCountryCode"
    private let cachedTimesKey = "cachedPrayerTimes"
    private let cachedDateKey = "cachedPrayerTimesDate"
    private let cachedCityIDKey = "cachedPrayerTimesCityID"

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
        if todaysTimes != nil, isCacheValid() {
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
            // Benachrichtigungen aktualisieren wenn aktiviert
            await scheduleNotificationsIfEnabled(times: times)
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
                // Demo-Daten für Entwicklung (Türkei und Deutschland oben)
                self.countries = [
                    Country(id: 1, name: "TÜRKIYE", code: "TURKEY"),
                    Country(id: 2, name: "ALMANYA", code: "GERMANY"),
                    Country(id: 3, name: "AVUSTURYA", code: "AUSTRIA"),
                    Country(id: 4, name: "İSVİÇRE", code: "SWITZERLAND")
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
                self.countries = self.sortCountriesWithPriority(countries)
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
            return
        }

        await MainActor.run {
            self.isLoading = true
        }

        do {
            let states = try await DiyanetAPI.shared.getStates(countryID: country.id)
            await MainActor.run {
                self.states = states.sorted { $0.displayName < $1.displayName }
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
            return
        }

        await MainActor.run {
            self.isLoading = true
        }

        do {
            let cities = try await DiyanetAPI.shared.getCities(stateID: state.id)
            await MainActor.run {
                self.cities = cities.sorted { $0.displayName < $1.displayName }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// Setzt den ausgewählten Standort (nur City)
    func setLocation(city: City) {
        selectedCity = city
        todaysTimes = nil
        saveLocation()
        Task {
            await fetchTodaysTimes()
        }
    }

    /// Setzt den kompletten Standort (Country, State, City)
    func setFullLocation(country: Country, state: DiyanetState, city: City) {
        selectedCountry = country
        selectedState = state
        selectedCity = city
        todaysTimes = nil
        saveLocation()
        Task {
            await fetchTodaysTimes()
        }
    }

    /// Öffentliche Methode zum Speichern des Standorts (für Onboarding)
    func saveLocationPublic() {
        saveLocation()
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
            let cityCode = defaults.string(forKey: cityCodeKey)
            selectedCity = City(id: cityID, name: cityName, stateID: stateID, code: cityCode)
        }

        if let stateID = defaults.object(forKey: stateIDKey) as? Int,
           let stateName = defaults.string(forKey: stateNameKey),
           let countryID = defaults.object(forKey: countryIDKey) as? Int {
            let stateCode = defaults.string(forKey: stateCodeKey)
            selectedState = DiyanetState(id: stateID, name: stateName, countryID: countryID, code: stateCode)
        }

        if let countryID = defaults.object(forKey: countryIDKey) as? Int,
           let countryName = defaults.string(forKey: countryNameKey) {
            let countryCode = defaults.string(forKey: countryCodeKey)
            selectedCountry = Country(id: countryID, name: countryName, code: countryCode)
        }
    }

    /// Speichert den ausgewählten Standort
    private func saveLocation() {
        let defaults = UserDefaults.standard

        if let city = selectedCity {
            defaults.set(city.id, forKey: cityIDKey)
            defaults.set(city.name, forKey: cityNameKey)
            defaults.set(city.code, forKey: cityCodeKey)
            // stateID von selectedState nehmen, da API es nicht liefert
            if let state = selectedState {
                defaults.set(state.id, forKey: stateIDKey)
            }
        }

        if let state = selectedState {
            defaults.set(state.id, forKey: stateIDKey)
            defaults.set(state.name, forKey: stateNameKey)
            defaults.set(state.code, forKey: stateCodeKey)
            // countryID von selectedCountry nehmen, da API es nicht liefert
            if let country = selectedCountry {
                defaults.set(country.id, forKey: countryIDKey)
            }
        }

        if let country = selectedCountry {
            defaults.set(country.id, forKey: countryIDKey)
            defaults.set(country.name, forKey: countryNameKey)
            defaults.set(country.code, forKey: countryCodeKey)
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
            if let cityID = selectedCity?.id {
                defaults.set(cityID, forKey: cachedCityIDKey)
            }
        }
    }

    /// Prüft ob der Cache noch gültig ist (heute) und für die aktuelle Stadt
    private func isCacheValid() -> Bool {
        let defaults = UserDefaults.standard
        guard let cachedDate = defaults.string(forKey: cachedDateKey),
              let selectedCityID = selectedCity?.id,
              let cachedCityID = defaults.object(forKey: cachedCityIDKey) as? Int else {
            return false
        }
        return cachedDate == dateFormatter.string(from: Date()) && cachedCityID == selectedCityID
    }

    /// Sortiert Länder mit Türkei und Deutschland immer oben
    private func sortCountriesWithPriority(_ countries: [Country]) -> [Country] {
        // Prioritäts-Länder: Türkei (TURKIYE) und Deutschland (GERMANY)
        let priorityNames = ["TURKIYE", "TÜRKIYE", "TURKEY", "GERMANY", "ALMANYA", "DEUTSCHLAND"]

        var priority: [Country] = []
        var rest: [Country] = []

        for country in countries {
            let nameUpper = country.name.uppercased()
            let codeUpper = (country.code ?? "").uppercased()

            if priorityNames.contains(nameUpper) || priorityNames.contains(codeUpper) {
                priority.append(country)
            } else {
                rest.append(country)
            }
        }

        // Türkei zuerst, dann Deutschland
        priority.sort { c1, c2 in
            let name1 = c1.name.uppercased()
            let name2 = c2.name.uppercased()
            let isTurkey1 = name1.contains("TURK") || name1.contains("TÜRK")
            let isTurkey2 = name2.contains("TURK") || name2.contains("TÜRK")

            if isTurkey1 && !isTurkey2 { return true }
            if !isTurkey1 && isTurkey2 { return false }
            return c1.displayName < c2.displayName
        }

        // Rest alphabetisch
        rest.sort { $0.displayName < $1.displayName }

        return priority + rest
    }

    /// Plant Benachrichtigungen wenn sie aktiviert sind
    private func scheduleNotificationsIfEnabled(times: PrayerTimes) async {
        let enabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        guard enabled, let cityName = selectedCity?.name else { return }

        await PrayerNotificationManager.shared.scheduleNotifications(for: times, cityName: cityName)
    }
}

