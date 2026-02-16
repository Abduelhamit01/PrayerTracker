//
//  PrayerTimeManager.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 28.01.26.
//

import Foundation
import SwiftUI
import Combine
import WidgetKit

// MARK: - Prayer Time Manager

class PrayerTimeManager: ObservableObject {
    // MARK: - Published Properties
    @Published var todaysTimes: PrayerTimes?
    @Published var tomorrowTimes: PrayerTimes?
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
    // Monthly cache keys
    private let cachedMonthlyTimesKey = "cachedMonthlyPrayerTimes"
    private let cachedMonthKey = "cachedPrayerTimesMonth"
    private let cachedMonthlyCityIDKey = "cachedMonthlyPrayerTimesCityID"

    // Old cache keys (for migration cleanup)
    private let oldCachedTimesKey = "cachedPrayerTimes"
    private let oldCachedDateKey = "cachedPrayerTimesDate"
    private let oldCachedCityIDKey = "cachedPrayerTimesCityID"

    // MARK: - DateFormatters
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.yyyy"
        return formatter
    }()

    // MARK: - Initialization

    init() {
        loadSavedLocation()
        loadCachedTimes()
        cleanupOldCacheKeys()
    }

    // MARK: - Public Methods

    /// Lädt die heutigen Gebetszeiten (monatliches Caching)
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

        // Daten bereits im Speicher und Cache gültig → nichts tun
        let todayString = dateFormatter.string(from: Date())
        if todaysTimes != nil, todaysTimes?.gregorianDateShort == todayString, isMonthCacheValid() {
            return
        }

        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let tomorrowString = dateFormatter.string(from: tomorrow)

        // Monats-Cache gültig → Lookup aus Cache, kein API-Call
        if isMonthCacheValid() {
            let cached = loadMonthlyTimesFromDefaults()
            let todayLookup = timesForDate(todayString, from: cached)
            let tomorrowLookup = timesForDate(tomorrowString, from: cached)

            if let todayLookup {
                await MainActor.run {
                    self.todaysTimes = todayLookup
                    self.tomorrowTimes = tomorrowLookup
                }
                updateWidgetDefaults(today: todayLookup, tomorrow: tomorrowLookup)
                await scheduleNotificationsIfEnabled(times: todayLookup)

                // Monatsgrenze: morgen ist neuer Monat aber nicht im Cache
                if tomorrowLookup == nil {
                    await fetchNextMonthTomorrow(cityID: cityID, tomorrowString: tomorrowString)
                }
                return
            }
        }

        // Cache ungültig → Monthly-Fetch
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }

        do {
            let monthlyTimes = try await DiyanetAPI.shared.getMonthlyPrayerTimes(cityID: cityID)
            let todayLookup = timesForDate(todayString, from: monthlyTimes)
            let tomorrowLookup = timesForDate(tomorrowString, from: monthlyTimes)

            await MainActor.run {
                self.todaysTimes = todayLookup ?? .placeholder
                self.tomorrowTimes = tomorrowLookup
                self.isLoading = false
            }

            cacheMonthlyTimes(monthlyTimes)

            if let todayLookup {
                updateWidgetDefaults(today: todayLookup, tomorrow: tomorrowLookup)
                await scheduleNotificationsIfEnabled(times: todayLookup)
            }

            // Monatsgrenze: morgen ist neuer Monat
            if tomorrowLookup == nil {
                await fetchNextMonthTomorrow(cityID: cityID, tomorrowString: tomorrowString)
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
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
            WidgetCenter.shared.reloadAllTimelines()
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
            WidgetCenter.shared.reloadAllTimelines()
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

        // City laden (stateID ist optional)
        if let cityID = defaults.object(forKey: cityIDKey) as? Int,
           let cityName = defaults.string(forKey: cityNameKey) {
            let cityCode = defaults.string(forKey: cityCodeKey)
            let stateID = defaults.object(forKey: stateIDKey) as? Int
            selectedCity = City(id: cityID, name: cityName, stateID: stateID, code: cityCode)
        }

        // State laden (countryID ist optional)
        if let stateID = defaults.object(forKey: stateIDKey) as? Int,
           let stateName = defaults.string(forKey: stateNameKey) {
            let stateCode = defaults.string(forKey: stateCodeKey)
            let countryID = defaults.object(forKey: countryIDKey) as? Int
            selectedState = DiyanetState(id: stateID, name: stateName, countryID: countryID, code: stateCode)
        }

        // Country laden
        if let countryID = defaults.object(forKey: countryIDKey) as? Int,
           let countryName = defaults.string(forKey: countryNameKey) {
            let countryCode = defaults.string(forKey: countryCodeKey)
            selectedCountry = Country(id: countryID, name: countryName, code: countryCode)
        }
    }

    /// Speichert den ausgewählten Standort
    private func saveLocation() {
        let defaults = UserDefaults.standard

        // Country speichern
        if let country = selectedCountry {
            defaults.set(country.id, forKey: countryIDKey)
            defaults.set(country.name, forKey: countryNameKey)
            defaults.set(country.code, forKey: countryCodeKey)
        }

        // State speichern
        if let state = selectedState {
            defaults.set(state.id, forKey: stateIDKey)
            defaults.set(state.name, forKey: stateNameKey)
            defaults.set(state.code, forKey: stateCodeKey)
        }

        // City speichern
        if let city = selectedCity {
            defaults.set(city.id, forKey: cityIDKey)
            defaults.set(city.name, forKey: cityNameKey)
            defaults.set(city.code, forKey: cityCodeKey)
        }

        // Sofort auf Disk schreiben (wichtig bei App-Kill)
        defaults.synchronize()
    }

    /// Lädt gecachte Gebetszeiten (monatlich)
    private func loadCachedTimes() {
        guard isMonthCacheValid() else {
            todaysTimes = .placeholder
            return
        }

        let cached = loadMonthlyTimesFromDefaults()
        let todayString = dateFormatter.string(from: Date())
        let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowString = dateFormatter.string(from: tomorrowDate)

        if let today = timesForDate(todayString, from: cached) {
            todaysTimes = today
            tomorrowTimes = timesForDate(tomorrowString, from: cached)
        } else {
            todaysTimes = .placeholder
        }
    }

    /// Lädt das monatliche Array aus UserDefaults
    private func loadMonthlyTimesFromDefaults() -> [PrayerTimes] {
        guard let data = UserDefaults.standard.data(forKey: cachedMonthlyTimesKey),
              let times = try? JSONDecoder().decode([PrayerTimes].self, from: data) else {
            return []
        }
        return times
    }

    /// Sucht in einem [PrayerTimes]-Array den Eintrag für ein bestimmtes Datum
    private func timesForDate(_ dateString: String, from times: [PrayerTimes]) -> PrayerTimes? {
        times.first { $0.gregorianDateShort == dateString }
    }

    /// Speichert monatliche Gebetszeiten im Cache (Standard + App Group)
    private func cacheMonthlyTimes(_ times: [PrayerTimes]) {
        if let data = try? JSONEncoder().encode(times) {
            // Standard UserDefaults (App-interner Cache)
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: cachedMonthlyTimesKey)
            defaults.set(monthFormatter.string(from: Date()), forKey: cachedMonthKey)
            if let cityID = selectedCity?.id {
                defaults.set(cityID, forKey: cachedMonthlyCityIDKey)
            }

            // App Group (für Widgets)
            let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")
            shared?.set(data, forKey: "widgetMonthlyPrayerTimes")
        }
    }

    /// Schreibt Today/Tomorrow + Monatsdaten + CityName in die App Group für Widgets
    private func updateWidgetDefaults(today: PrayerTimes, tomorrow: PrayerTimes?) {
        let shared = UserDefaults(suiteName: "group.com.Abduelhamit.PrayerTracker")
        if let todayData = try? JSONEncoder().encode(today) {
            shared?.set(todayData, forKey: "widgetPrayerTimes")
        }
        shared?.set(selectedCity?.displayName, forKey: "widgetCityName")

        if let tomorrow, let tomorrowData = try? JSONEncoder().encode(tomorrow) {
            shared?.set(tomorrowData, forKey: "widgetTomorrowPrayerTimes")
        }

        // Monatsdaten immer in App Group synchronisieren (auch aus Cache-Pfad)
        if let monthlyData = UserDefaults.standard.data(forKey: cachedMonthlyTimesKey) {
            shared?.set(monthlyData, forKey: "widgetMonthlyPrayerTimes")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Fetcht den nächsten Monat um die morgige Gebetszeit an der Monatsgrenze zu bekommen
    private func fetchNextMonthTomorrow(cityID: Int, tomorrowString: String) async {
        do {
            let nextMonthTimes = try await DiyanetAPI.shared.getMonthlyPrayerTimes(cityID: cityID)
            let tomorrowLookup = timesForDate(tomorrowString, from: nextMonthTimes)
            await MainActor.run {
                self.tomorrowTimes = tomorrowLookup
            }
            if let todaysTimes, let tomorrowLookup {
                updateWidgetDefaults(today: todaysTimes, tomorrow: tomorrowLookup)
            }
        } catch {
            // Nächster Monat konnte nicht geladen werden - nicht kritisch
        }
    }

    /// Prüft ob der Monats-Cache noch gültig ist
    private func isMonthCacheValid() -> Bool {
        let defaults = UserDefaults.standard
        guard let cachedMonth = defaults.string(forKey: cachedMonthKey),
              let selectedCityID = selectedCity?.id,
              let cachedCityID = defaults.object(forKey: cachedMonthlyCityIDKey) as? Int else {
            return false
        }
        return cachedMonth == monthFormatter.string(from: Date()) && cachedCityID == selectedCityID
    }

    /// Einmalige Migration: alte Cache-Keys entfernen
    private func cleanupOldCacheKeys() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: oldCachedTimesKey)
        defaults.removeObject(forKey: oldCachedDateKey)
        defaults.removeObject(forKey: oldCachedCityIDKey)
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

