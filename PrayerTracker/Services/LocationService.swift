//
//  LocationService.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 29.01.26.
//

import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    private let locationManager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var currentCity: String?
    @Published var currentCountry: String?
    @Published var currentCountryCode: String?  // ISO Code wie "DE", "TR", "US"

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Methods

    /// Fragt nach Standort-Berechtigung
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Fragt nach Standort-Berechtigung und wartet auf Antwort (async)
    func requestPermissionAsync() async -> Bool {
        // Wenn schon entschieden, sofort zurückgeben
        if authorizationStatus != .notDetermined {
            return isAuthorized
        }

        locationManager.requestWhenInUseAuthorization()

        // Warte bis Status sich ändert (max 30 Sekunden für User-Entscheidung)
        for _ in 0..<60 {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s

            if authorizationStatus != .notDetermined {
                return isAuthorized
            }
        }

        return false
    }

    /// Holt den aktuellen Standort
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        locationManager.requestLocation()
    }

    /// Holt den aktuellen Standort und wartet auf Geocoding (async)
    func requestLocationAsync() async -> (city: String?, country: String?, countryCode: String?) {
        guard isAuthorized else {
            return (nil, nil, nil)
        }

        // Reset current values
        await MainActor.run {
            self.currentCity = nil
            self.currentCountry = nil
            self.currentCountryCode = nil
        }

        locationManager.requestLocation()

        // Warte auf Geocoding (max 10 Sekunden)
        for _ in 0..<20 {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s

            if let city = currentCity, let country = currentCountry {
                return (city, country, currentCountryCode)
            }
        }

        return (currentCity, currentCountry, currentCountryCode)
    }

    /// Prüft ob Berechtigung erteilt wurde
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    /// Prüft ob Berechtigung verweigert wurde
    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus

            // Automatisch Standort abrufen wenn berechtigt
            if self.isAuthorized {
                self.requestLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        DispatchQueue.main.async {
            self.currentLocation = location
        }

        // Reverse Geocoding um Stadt/Land zu ermitteln
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if error != nil {
                return
            }

            guard let self = self,
                  let placemark = placemarks?.first else {
                return
            }

            DispatchQueue.main.async {
                self.currentCity = placemark.locality
                self.currentCountry = placemark.country
                self.currentCountryCode = placemark.isoCountryCode
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location error - handled silently
    }
}
