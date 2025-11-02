//
//  PalabraWidgetLiveActivity.swift
//  PalabraWidget
//
//  Created by Developer on 11/1/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PalabraWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PalabraWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PalabraWidgetAttributes.self) { context in
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

extension PalabraWidgetAttributes {
    fileprivate static var preview: PalabraWidgetAttributes {
        PalabraWidgetAttributes(name: "World")
    }
}

extension PalabraWidgetAttributes.ContentState {
    fileprivate static var smiley: PalabraWidgetAttributes.ContentState {
        PalabraWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PalabraWidgetAttributes.ContentState {
         PalabraWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PalabraWidgetAttributes.preview) {
   PalabraWidgetLiveActivity()
} contentStates: {
    PalabraWidgetAttributes.ContentState.smiley
    PalabraWidgetAttributes.ContentState.starEyes
}
