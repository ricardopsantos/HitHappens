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
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
            Text("Favorite Emoji:")
            Text(entry.model.emoji)
        }
    }
}

#Preview(as: .systemMedium) {
    Favorits()
} timeline: {
    TimelineEntryModel(date: .now, model: .smiley)
    TimelineEntryModel(date: .now, model: .starEyes)
}
