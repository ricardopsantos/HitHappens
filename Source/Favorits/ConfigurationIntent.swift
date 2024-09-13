//
//  AppIntent.swift
//  Favorits
//
//  Created by Ricardo Santos on 12/09/2024.
//

import WidgetKit
import AppIntents
//
import Common
import Domain

struct ConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Favorites"
    static var description = IntentDescription("Favorites widget.")

    @Parameter(title: "Favorite Name", default: "123123")
    var name: String

    @Parameter(title: "Favorite Current Counter Value", default: 2)
    var counter: Int

    @Parameter(title: "Counter ID", default: "")
    var id: String
}

extension ConfigurationIntent {
    static var mock1: Self {
        let configuration = ConfigurationIntent()
        configuration.name = "name_1"
        configuration.counter = 1
        return configuration
    }

    static var mock2: Self {
        let configuration = ConfigurationIntent()
        configuration.name = "name_2"
        configuration.counter = 2
        return configuration
    }
}

#Preview(as: .systemSmall) {
    Favorits()
} timeline: {
    TimelineEntryModel(date: .now, model: .mock1)
    TimelineEntryModel(date: .now, model: .mock2)
}
