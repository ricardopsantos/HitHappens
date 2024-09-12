//
//  AppIntentTimelineProvider.swift
//  Favorits
//
//  Created by Ricardo Santos on 12/09/2024.
//

import WidgetKit
import SwiftUI
//
import DesignSystem
import Core
import Domain

struct Favorits: Widget {
    let dataBaseRepository: DataBaseRepositoryProtocol
    init() {
        self.dataBaseRepository = DependenciesManager.Repository.dataBaseRepository
    }

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Constants.kind,
            intent: ConfigurationIntent.self,

            provider: Provider(dataBaseRepository: dataBaseRepository)
        ) { entry in
            FavoritsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(Constants.configurationDisplayName)
        .description(Constants.description)
        .supportedFamilies([
            .systemMedium,
            .systemLarge
        ])
    }
}

#Preview(as: .systemMedium) {
    Favorits()
} timeline: {
    TimelineEntryModel(date: .now, model: .smiley)
    TimelineEntryModel(date: .now, model: .starEyes)
}
