//
//  LocationPickerView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 28.01.26.
//

import SwiftUI

struct LocationPickerView: View {
    @ObservedObject var prayerTimeManager: PrayerTimeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Country Selection
                Section(header: Text("country")) {
                    if prayerTimeManager.countries.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(prayerTimeManager.countries) { country in
                            Button {
                                Task {
                                    await prayerTimeManager.fetchStates(for: country)
                                }
                            } label: {
                                HStack {
                                    Text(country.displayName)
                                        .foregroundStyle(.primary)
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

                // MARK: - State Selection
                if !prayerTimeManager.states.isEmpty {
                    Section(header: Text("state")) {
                        ForEach(prayerTimeManager.states) { state in
                            Button {
                                Task {
                                    await prayerTimeManager.fetchCities(for: state)
                                }
                            } label: {
                                HStack {
                                    Text(state.displayName)
                                        .foregroundStyle(.primary)
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

                // MARK: - City Selection
                if !prayerTimeManager.cities.isEmpty {
                    Section(header: Text("city")) {
                        ForEach(prayerTimeManager.cities) { city in
                            Button {
                                prayerTimeManager.setLocation(city: city)
                                dismiss()
                            } label: {
                                HStack {
                                    Text(city.displayName)
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

                // MARK: - Error Message
                if let error = prayerTimeManager.error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("select_location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done") {
                        dismiss()
                    }
                }
            }
            .task {
                if prayerTimeManager.countries.isEmpty {
                    await prayerTimeManager.fetchCountries()
                }
            }
        }
    }
}

#Preview {
    LocationPickerView(prayerTimeManager: PrayerTimeManager())
}
