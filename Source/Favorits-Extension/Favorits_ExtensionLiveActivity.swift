//
//  Favorits_ExtensionLiveActivity.swift
//  Favorits-Extension
//
//  Created by Ricardo Santos on 12/09/2024.
//
/*
import ActivityKit
import WidgetKit
import SwiftUI

struct Favorits_ExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Favorits_ExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Favorits_ExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Favorits_ExtensionAttributes {
    fileprivate static var preview: Favorits_ExtensionAttributes {
        Favorits_ExtensionAttributes(name: "World")
    }
}

extension Favorits_ExtensionAttributes.ContentState {
    fileprivate static var smiley: Favorits_ExtensionAttributes.ContentState {
        Favorits_ExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Favorits_ExtensionAttributes.ContentState {
         Favorits_ExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Favorits_ExtensionAttributes.preview) {
   Favorits_ExtensionLiveActivity()
} contentStates: {
    Favorits_ExtensionAttributes.ContentState.smiley
    Favorits_ExtensionAttributes.ContentState.starEyes
}
*/
