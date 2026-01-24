//
//  PalabraWidget.swift
//  PalabraWidget
//
//  Created by Developer on 11/1/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            wordID: "hablar",
            word: WordEntry(
                id: "hablar",
                spanish: "hablar",
                english: "to speak; to talk",
                examples: []
            )
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let word = loadWords().first
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            wordID: word?.id,
            word: word
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let store = SharedWordStore.shared
        let calendar = Calendar.current
        let now = Date()
        let words = loadWords()
        let wordsByID = Dictionary(uniqueKeysWithValues: words.map { ($0.id, $0) })

        guard let schedule = store.loadSchedule(),
              calendar.isDate(schedule.date, inSameDayAs: now),
              !schedule.slots.isEmpty else {
            let entry = SimpleEntry(date: now, configuration: configuration, wordID: nil, word: nil)
            return Timeline(entries: [entry], policy: .after(calendar.date(byAdding: .hour, value: 1, to: now) ?? now.addingTimeInterval(3600)))
        }

        let entries = schedule.slots
            .sorted { $0.start < $1.start }
            .map { slot in
                SimpleEntry(
                    date: slot.start,
                    configuration: configuration,
                    wordID: slot.wordID,
                    word: wordsByID[slot.wordID]
                )
            }

        return Timeline(entries: entries, policy: .atEnd)
    }

    private func loadWords() -> [WordEntry] {
        do {
            return try WordBundleLoader.load()
        } catch {
            return []
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let wordID: String?
    let word: WordEntry?
}

struct PalabraWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(entry.word?.spanish ?? "Palabrita")
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.word?.spanish ?? "Palabrita")
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(entry.word?.english ?? "Spanish word")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        default:
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.word?.spanish ?? "Palabrita")
                    .font(.system(size: 28, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(entry.word?.english ?? "Spanish word of the day")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

struct PalabraWidget: Widget {
    let kind: String = "PalabraWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PalabraWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryInline, .accessoryRectangular])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    PalabraWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: .smiley,
        wordID: "hablar",
        word: WordEntry(id: "hablar", spanish: "hablar", english: "to speak; to talk", examples: [])
    )
    SimpleEntry(
        date: .now,
        configuration: .starEyes,
        wordID: "casa",
        word: WordEntry(id: "casa", spanish: "casa", english: "house; home", examples: [])
    )
}
