//
//  NextPrayerWidgetBundle.swift
//  NextPrayerWidget
//
//  Created by Abdülhamit Oral on 07.02.26.
//

import WidgetKit
import SwiftUI

@main
struct NextPrayerWidgetBundle: WidgetBundle {
    var body: some Widget {
        NextPrayerWidget()
        AllPrayerTimesWidget()
        NextPrayerLockScreenWidget()
    }
}
