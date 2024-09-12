//
//  FavoritsBundle.swift
//  Favorits
//
//  Created by Ricardo Santos on 12/09/2024.
//

import WidgetKit
import SwiftUI
//
import Domain

@main
struct FavoritsBundle: WidgetBundle {
    init() {
        Domain.coreDataPersistence = .appGroup(identifier: "group.com.hit.happens.app.id")
    }
    var body: some Widget {
        Favorits()
    }
}

#Preview(as: .systemSmall) {
    Favorits()
} timeline: {
    TimelineEntryModel(date: .now, model: .smiley)
    TimelineEntryModel(date: .now, model: .starEyes)
}
