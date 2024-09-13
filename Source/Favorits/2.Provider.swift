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

    /// Purpose: Defines how often the widget updates. It generates a timeline with multiple entries based on the configuration.
    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<TimelineEntryModel> {
        var entries: [TimelineEntryModel] = []

        // Generate a timeline consisting of five entries
        let currentDate = Date()
        for offSet in 0..<5 {
            let entryDate = Calendar.current.date(
                byAdding: .second,
                value: offSet,
                to: currentDate)!
            let entry = TimelineEntryModel(date: entryDate, model: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    /// Purpose: Provides a placeholder for the widget's display when no actual data is available.
    func placeholder(in context: Context) -> TimelineEntryModel {
        if let first = Self.favorits.sorted(by: { $0.name > $1.name }).first {
            let model = ConfigurationIntent()
            model.name = first.name
            model.counter = first.cascadeEvents?.count ?? 0
            return TimelineEntryModel(date: Date(), model: model)
        } else {
            return TimelineEntryModel(date: Date(), model: ConfigurationIntent())
        }
    }

    /// Purpose: Provides a snapshot for the widget when in a transient state (e.g., in the widget gallery).
    func snapshot(
        for configuration: ConfigurationIntent,
        in context: Context) async -> TimelineEntryModel {
        TimelineEntryModel(date: Date(), model: configuration)
    }
}

#Preview(as: .systemSmall) {
    Favorits()
} timeline: {
    TimelineEntryModel(date: .now, model: .mock1)
    TimelineEntryModel(date: .now, model: .mock2)
}
