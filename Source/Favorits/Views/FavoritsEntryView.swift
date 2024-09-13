//
//  FavoritsEntryView.swift
//  Favorits
//
//  Created by Ricardo Santos on 12/09/2024.
//

import WidgetKit
import SwiftUI
//
import DesignSystem
import Common
import Domain

struct FavoritsEntryView: View {
    let dataBaseRepository: DataBaseRepositoryProtocol
    var entry: Provider.Entry
    var body: some View {
        VStack {
            HStack {
                Text("Name:")
                Text(entry.model.name)
            }
            HStack {
                Text("Counter:")
                Text(entry.model.counter.description)
            }
            Button("Increment") {
                dataBaseRepository.trackedLogInsertOrUpdate(
                    trackedLog:
                    .init(
                        latitude: 0,
                        longitude: 0,
                        addressMin: "",
                        note: ""
                    ),

                    trackedEntityId: entry.model.id
                )
            }
        }
    }
}

#Preview(as: .systemSmall) {
    Favorits()
} timeline: {
    TimelineEntryModel(date: .now, model: .mock1)
    TimelineEntryModel(date: .now, model: .mock2)
}
