//
//  AppInstallDate.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 07.01.26.
//

import Foundation

class AppInstallDate {
    static let shared = AppInstallDate()

    private let key = "appInstallDate"

    var installDate: Date {
        if let savedDate = UserDefaults.standard.object(forKey: key) as? Date {
            return savedDate
        } else {
            // Erstes Mal - speichere heutiges Datum
            let today = Date()
            UserDefaults.standard.set(today, forKey: key)
            return today
        }
    }

    private init() {}
}
