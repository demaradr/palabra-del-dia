//
//  ContentView.swift
//  PalabraDD
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    // When true, we show mock data and skip loading from disk (great for Previews)
    let useMockData: Bool

    @State private var status: String = "Loading…"
    @State private var words: [WordEntry] = []
    @State private var currentWord: WordEntry?
    @State private var historyIDs: [String] = []
    @State private var showingSettings: Bool = false
    @State private var scheduleSettings: WordScheduleSettings = .defaultSettings

    init(useMockData: Bool = false) {
        self.useMockData = useMockData
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer(minLength: 32)

                ZStack {
                    if let word = currentWord {
                        VStack(alignment: .center, spacing: 8) {
                            Text(word.spanish)
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            Text(word.english)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .id(word.id)
                    } else {
                        VStack(alignment: .center, spacing: 8) {
                            Text("Hello, Palabrify!")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text(status)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer(minLength: 28)

                ZStack {
                    if let word = currentWord, !word.examples.isEmpty {
                        VStack(alignment: .center, spacing: 18) {
                            ForEach(word.examples.indices, id: \.self) { index in
                                ExampleSentenceView(example: word.examples[index])
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .id(word.id + ".examples")
                    } else {
                        Text("No examples yet.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 28)

                Spacer(minLength: 28)

                ZStack {
                    if let word = currentWord {
                        Button {
                            playPronunciation(for: word)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Color(red: 0.55, green: 0.24, blue: 0.24))
                                .frame(width: 64, height: 64)
                                .background(
                                    Circle()
                                        .fill(Color(red: 0.95, green: 0.84, blue: 0.84))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 10)
                        .transition(.scale.combined(with: .opacity))
                        .id(word.id + ".audio")
                    }
                }

                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 64)

                Image(systemName: "chevron.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.secondary.opacity(0.45))
                    .padding(.top, 10)

                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.99, green: 0.97, blue: 0.95))
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: currentWord?.id)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        if value.translation.height < -60 {
                            requestNextWord()
                        }
                    }
            )
            .navigationTitle("Palabrita")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink("History") {
                        WordHistoryView(words: words, historyIDs: historyIDs)
                    }
                    Button("Settings") {
                        showingSettings = true
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                ScheduleSettingsView(
                    settings: scheduleSettings,
                    onSave: { newSettings in
                        scheduleSettings = newSettings
                        SharedWordStore.shared.saveScheduleSettings(newSettings)
                        loadInitialWord()
                        showingSettings = false
                    }
                )
                .interactiveDismissDisabled(storeNeedsSetup)
            }
            // Only do the expensive load when not in mock/preview mode
            .task {
                guard !useMockData else {
                    let mock = WordEntry(
                        id: "hablar",
                        spanish: "hablar",
                        english: "to speak; to talk",
                        examples: [ExampleSentence(spanish: "Quiero hablar contigo.", english: "I want to talk with you.")]
                    )
                    words = [mock]
                    currentWord = mock
                    historyIDs = [mock.id]
                    status = "Preview (mock data)"
                    return
                }

                loadInitialWord()
            }
        }
    }

    private func loadInitialWord() {
        do {
            let store = SharedWordStore.shared
            let loadedWords = try WordBundleLoader.load()
            words = loadedWords
            historyIDs = store.loadHistoryIDs()
            scheduleSettings = store.loadScheduleSettings() ?? .defaultSettings
            if store.loadScheduleSettings() == nil {
                showingSettings = true
            }

            let scheduler = WordScheduler(words: loadedWords)
            let schedule = scheduler.loadOrCreateSchedule(store: store, settings: scheduleSettings)
            let currentID = scheduler.currentWordID(for: Date(), schedule: schedule)
            let resolvedWord = loadedWords.first { $0.id == currentID } ?? {
                if let storedID = store.loadCurrentWordID() {
                    return loadedWords.first { $0.id == storedID }
                }
                return nil
            }() ?? loadedWords.first

            guard let word = resolvedWord else {
                status = "No words found"
                return
            }

            setCurrentWord(word, animated: false)
        } catch {
            status = "Load error: \(error.localizedDescription)"
            print("Load error:", error)
        }
    }

    private func requestNextWord() {
        do {
            let store = SharedWordStore.shared
            let source = try BundledWordSource(seenIDs: Set(store.loadSeenWordIDs()))
            guard let next = source.nextWord() else {
                status = "No words found"
                return
            }
            setCurrentWord(next, animated: true)
        } catch {
            status = "Load error: \(error.localizedDescription)"
            print("Load error:", error)
        }
    }

    private func setCurrentWord(_ word: WordEntry, animated: Bool) {
        let store = SharedWordStore.shared
        print("Selected word:", word.spanish, "-", word.english)
        if animated {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                currentWord = word
            }
        } else {
            currentWord = word
        }
        store.saveCurrentWordID(word.id)
        store.markSeen(word.id)
        store.appendHistory(word.id)
        historyIDs = store.loadHistoryIDs()
        WidgetCenter.shared.reloadAllTimelines()
        status = "Loaded word"
    }

    private func playPronunciation(for word: WordEntry) {
        PronunciationService.shared.speak(word.spanish)
    }

    private var storeNeedsSetup: Bool {
        SharedWordStore.shared.loadScheduleSettings() == nil
    }
}

#Preview("Preview (mock, no simulator)") {
    // This uses mock data so it renders instantly in the canvas
    ContentView(useMockData: true)
}

// If you want to test the *real* loader inside the preview and see console logs,
// add this second preview. It may be a bit slower, so keep it commented unless needed.
/*
#Preview("Preview (real load)") {
    ContentView()
}
*/

private struct ExampleSentenceView: View {
    let example: ExampleSentence

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(example.spanish)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Text(example.english)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, 6)
    }
}

private struct WordHistoryView: View {
    let words: [WordEntry]
    let historyIDs: [String]

    var body: some View {
        List {
            if historyIDs.isEmpty {
                Text("No history yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(historyWords, id: \.id) { word in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(word.spanish)
                            .font(.headline.weight(.semibold))
                        Text(word.english)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("History")
        .scrollContentBackground(.hidden)
        .background(Color(red: 0.99, green: 0.97, blue: 0.95))
    }

    private var historyWords: [WordEntry] {
        let map = Dictionary(uniqueKeysWithValues: words.map { ($0.id, $0) })
        return historyIDs.reversed().compactMap { map[$0] }
    }
}

private struct ScheduleSettingsView: View {
    @State private var wordsPerDay: Int
    @State private var startTime: Date
    @State private var endTime: Date

    let onSave: (WordScheduleSettings) -> Void

    init(settings: WordScheduleSettings, onSave: @escaping (WordScheduleSettings) -> Void) {
        _wordsPerDay = State(initialValue: settings.wordsPerDay)
        _startTime = State(initialValue: ScheduleSettingsView.dateFromMinutes(settings.startMinutes))
        _endTime = State(initialValue: ScheduleSettingsView.dateFromMinutes(settings.endMinutes))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily window") {
                    DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                    Text(windowDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Words per day") {
                    Stepper(value: $wordsPerDay, in: 1...15) {
                        Text("\(wordsPerDay) words")
                    }
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(WordScheduleSettings(wordsPerDay: wordsPerDay, startMinutes: startMinutes, endMinutes: endMinutes))
                    }
                }
            }
        }
    }

    private var startMinutes: Int {
        minutes(from: startTime)
    }

    private var endMinutes: Int {
        minutes(from: endTime)
    }

    private var windowDescription: String {
        let total = totalMinutes
        let hours = total / 60
        let minutes = total % 60
        if minutes == 0 {
            return "Window: \(hours) hours"
        }
        return "Window: \(hours)h \(minutes)m"
    }

    private var totalMinutes: Int {
        let start = startMinutes
        let end = endMinutes
        return end <= start ? (24 * 60 - start) + end : (end - start)
    }

    private func minutes(from date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }

    private static func dateFromMinutes(_ minutes: Int) -> Date {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .minute, value: minutes, to: startOfDay) ?? startOfDay
    }
}
