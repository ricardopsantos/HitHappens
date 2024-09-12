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

    @Parameter(title: "Favorites", default: "")
    var emoji: String

    @Parameter(title: "Favorite Name", default: "")
    var name: String

    @Parameter(title: "Favorite Current Counter Value", default: "0")
    var counter: String
}

extension ConfigurationIntent {
    static var smiley: ConfigurationIntent {
        let intent = ConfigurationIntent()
        intent.emoji = "😀"
        return intent
    }

    static var starEyes: ConfigurationIntent {
        let intent = ConfigurationIntent()
        intent.emoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    Favorits()
} timeline: {
    TimelineEntryModel(date: .now, model: .smiley)
    TimelineEntryModel(date: .now, model: .starEyes)
}
