//
//  QiblaManager.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 08.02.26.
//

import Foundation
import SwiftUI
import CoreLocation
import Combine

extension Double {
    func toRadians() -> Double { self * .pi / 180 }
    func toDegrees() -> Double { self * 180 / .pi }
}

class QiblaManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var qiblaSensor = CLLocationManager()
    private var standort: CLLocation? = nil
    
    @Published var winkelPfeil : Double = 0.0
    @Published var lookingToMekkah: Bool = false
    @Published var progress: Double = 0.0
    @Published var locationDenied: Bool = false
        
    // Der Sensor startet hier. Der Code wird beim start direkt ausgeführt umd die Location und Kompass zu bekommen.
    override init() {
        super.init()
        qiblaSensor.delegate = self
    }
    
    func start() {
        qiblaSensor.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationDenied = false
            qiblaSensor.startUpdatingHeading()
            qiblaSensor.startUpdatingLocation()
        } else if manager.authorizationStatus == .notDetermined {
            
        } else {
            locationDenied = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //guard let weil standort ja auch ein Nil liefern kann, wenn es keinen Standort empfangen kann
        guard let standort else {
            return
        }
        if newHeading.trueHeading >= 0 {
            winkelPfeil = qiblaBearing(from: standort.coordinate) - newHeading.trueHeading
            winkelPfeil = (winkelPfeil + 360).truncatingRemainder(dividingBy: 360)
            if winkelPfeil < 3 ||  winkelPfeil > 357 {
                lookingToMekkah = true
            } else {
                lookingToMekkah = false
            }
            
            if winkelPfeil <= 180 {
                progress = 1 - (winkelPfeil / 180)
            } else {
                 progress = 1 - ((360 - winkelPfeil) / 180)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        standort = locations.last
    }
    
    func qiblaBearing(from location: CLLocationCoordinate2D) -> Double {
        let kaaba = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
        
        let lat1 = location.latitude.toRadians()
        let lat2 = kaaba.latitude.toRadians()
        let deltaLon = (kaaba.longitude - location.longitude).toRadians()
        
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        
        let bearing = atan2(y, x).toDegrees()
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
}
