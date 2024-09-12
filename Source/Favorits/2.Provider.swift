//
//  AppIntentTimelineProvider.swift
//  Favorits
//
//  Created by Ricardo Santos on 12/09/2024.
//

import WidgetKit
import SwiftUI
import AppIntents
//
import DesignSystem
import Domain
import Common

/// an object that determines the timing of updates to the widget's view
struct Provider: AppIntentTimelineProvider {
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    static var favorits: [Model.TrackedEntity] = []
    public init(dataBaseRepository: DataBaseRepositoryProtocol?) {
        self.dataBaseRepository = dataBaseRepository
        if let records = dataBaseRepository?.trackedEntityGetAll(
            favorite: true,
            archived: false,
            cascade: true) {
            Self.favorits = records
        }
    }

    // ORDER: 1
    func placeholder(in context: Context) -> TimelineEntryModel {
        if let first = Self.favorits.first {
            let nameIntent: IntentParameter<String> = first.name.asIntentParameter
            let countIntent: IntentParameter<String> = (first.cascadeEvents?.count ?? 0).asIntentParameter
            let model: ConfigurationIntent = ConfigurationIntent(
                name: nameIntent,
                counter: countIntent)
            return TimelineEntryModel(date: Date(), model: model)
        } else {
            return TimelineEntryModel(date: Date(), model: ConfigurationIntent())
        }
    }

    func snapshot(for configuration: ConfigurationIntent, in context: Context) async -> TimelineEntryModel {
        TimelineEntryModel(date: Date(), model: configuration)
    }

    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<TimelineEntryModel> {
        var entries: [TimelineEntryModel] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = TimelineEntryModel(date: entryDate, model: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

extension Provider {
    func getFavorits() {
        if let records = dataBaseRepository?.trackedEntityGetAll(
            favorite: true,
            archived: false,
            cascade: true) {
            // favorits = records
        }
    }
}

#Preview(as: .systemSmall) {
    Favorits()
} timeline: {
    TimelineEntryModel(date: .now, model: .smiley)
    TimelineEntryModel(date: .now, model: .starEyes)
}
