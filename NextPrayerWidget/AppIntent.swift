//
//  AppIntent.swift
//  NextPrayerWidget
//
//  Created by Abdülhamit Oral on 07.02.26.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }
}
