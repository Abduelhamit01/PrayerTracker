//
//  LocationSelectionView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 29.01.26.
//

import SwiftUI

// MARK: - Location Selection Flow

struct LocationSelectionView: View {
    @ObservedObject var prayerTimeManager: PrayerTimeManager
    @Environment(\.dismiss) private var dismiss
    var onLocationSelected: (() -> Void)?

    @State private var searchText = ""

    private var filteredCountries: [Country] {
        if searchText.isEmpty {
            return prayerTimeManager.countries
        }
        return prayerTimeManager.countries.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            // MARK: - Country Selection
            if prayerTimeManager.countries.isEmpty {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            } else {
                Section(header: Text("country")) {
                    ForEach(filteredCountries) { country in
                        NavigationLink {
                            StateSelectionView(
                                prayerTimeManager: prayerTimeManager,
                                country: country,
                                onLocationSelected: onLocationSelected
                            )
                        } label: {
                            HStack {
                                Text(country.name)
                                Spacer()
                                if prayerTimeManager.selectedCountry?.id == country.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.islamicGreen)
                                }
                            }
                        }
                    }
                }
            }

            if let error = prayerTimeManager.error {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
        }
        .searchable(text: $searchText, prompt: "search")
        .navigationTitle("select_location")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if prayerTimeManager.countries.isEmpty {
                await prayerTimeManager.fetchCountries()
            }
        }
    }
}

// MARK: - State Selection

struct StateSelectionView: View {
    @ObservedObject var prayerTimeManager: PrayerTimeManager
    let country: Country
    var onLocationSelected: (() -> Void)?

    @State private var states: [DiyanetState] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var searchText = ""

    private var filteredStates: [DiyanetState] {
        if searchText.isEmpty {
            return states
        }
        return states.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            if isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            } else if states.isEmpty {
                Section {
                    Text("Keine Bundesländer gefunden")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section(header: Text("state")) {
                    ForEach(filteredStates) { state in
                        NavigationLink {
                            CitySelectionView(
                                prayerTimeManager: prayerTimeManager,
                                state: state,
                                onLocationSelected: onLocationSelected
                            )
                        } label: {
                            HStack {
                                Text(state.name)
                                Spacer()
                                if prayerTimeManager.selectedState?.id == state.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.islamicGreen)
                                }
                            }
                        }
                    }
                }
            }

            if let error = error {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
        }
        .searchable(text: $searchText, prompt: "search")
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadStates()
        }
    }

    private func loadStates() async {
        isLoading = true
        do {
            let fetchedStates = try await DiyanetAPI.shared.getStates(countryID: country.id)
            await MainActor.run {
                self.states = fetchedStates.sorted { $0.name < $1.name }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// MARK: - City Selection

struct CitySelectionView: View {
    @ObservedObject var prayerTimeManager: PrayerTimeManager
    let state: DiyanetState
    var onLocationSelected: (() -> Void)?

    @State private var cities: [City] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var searchText = ""

    private var filteredCities: [City] {
        if searchText.isEmpty {
            return cities
        }
        return cities.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            if isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            } else if cities.isEmpty {
                Section {
                    Text("Keine Städte gefunden")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section(header: Text("city")) {
                    ForEach(filteredCities) { city in
                        Button {
                            selectCity(city)
                        } label: {
                            HStack {
                                Text(city.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if prayerTimeManager.selectedCity?.id == city.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.islamicGreen)
                                }
                            }
                        }
                    }
                }
            }

            if let error = error {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
        }
        .searchable(text: $searchText, prompt: "search")
        .navigationTitle(state.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadCities()
        }
    }

    private func loadCities() async {
        isLoading = true
        do {
            let fetchedCities = try await DiyanetAPI.shared.getCities(stateID: state.id)
            await MainActor.run {
                self.cities = fetchedCities.sorted { $0.name < $1.name }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    private func selectCity(_ city: City) {
        prayerTimeManager.setLocation(city: city)
        // Callback um Settings zu schließen
        onLocationSelected?()
    }
}

#Preview {
    NavigationStack {
        LocationSelectionView(prayerTimeManager: PrayerTimeManager())
    }
}
