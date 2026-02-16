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
    @State private var filteredWords: [WordEntry] = []
    @State private var currentWord: WordEntry?
    @State private var historyIDs: [String] = []
    @State private var showingSettings: Bool = false
    @State private var scheduleSettings: WordScheduleSettings = .defaultSettings
    @State private var filterSettings: WordFilterSettings = .all
    @State private var languageSelectionID: String = LanguageCatalog.defaultID
    @State private var availableLevels: [String] = []
    @State private var availableCategories: [String] = []

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
                            Text(word.source)
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            Text(word.target)
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
                            ForEach(Array(word.examples.prefix(2)).indices, id: \.self) { index in
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
                    filterSettings: filterSettings,
                    languageSelectionID: languageSelectionID,
                    availableLevels: availableLevels,
                    availableCategories: availableCategories,
                    onSave: { newSettings, newFilters, newLanguageID in
                        scheduleSettings = newSettings
                        filterSettings = newFilters
                        languageSelectionID = newLanguageID
                        SharedWordStore.shared.saveScheduleSettings(newSettings)
                        SharedWordStore.shared.saveFilterSettings(newFilters)
                        SharedWordStore.shared.saveLanguageSelectionID(newLanguageID)
                        WidgetCenter.shared.reloadAllTimelines()
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
                        id: "es:hablar",
                        source: "hablar",
                        target: "to speak; to talk",
                        sourceLanguage: "es-ES",
                        targetLanguage: "en-US",
                        examples: [
                            ExampleSentence(source: "Quiero hablar contigo.", target: "I want to talk with you."),
                            ExampleSentence(source: "Hablamos despues de comer.", target: "We talk after lunch.")
                        ],
                        level: "beginner",
                        categories: ["daily-life", "communication"]
                    )
                    words = [mock]
                    filteredWords = [mock]
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
            languageSelectionID = store.loadLanguageSelectionID() ?? LanguageCatalog.defaultID
            let languageOption = LanguageCatalog.option(for: languageSelectionID)
            let loadedWords = try WordBundleLoader.load(fileName: languageOption.fileName)
            words = loadedWords
            historyIDs = store.loadHistoryIDs()
            scheduleSettings = store.loadScheduleSettings() ?? .defaultSettings
            filterSettings = store.loadFilterSettings() ?? .all
            availableLevels = Array(Set(loadedWords.map { $0.level })).sorted()
            availableCategories = Array(Set(loadedWords.flatMap { $0.categories })).sorted()
            if store.loadScheduleSettings() == nil {
                showingSettings = true
            }

            let usableWords = applyFilters(to: loadedWords, settings: filterSettings)
            filteredWords = usableWords.isEmpty ? loadedWords : usableWords

            let scheduler = WordScheduler(words: filteredWords)
            let schedule = scheduler.loadOrCreateSchedule(store: store, settings: scheduleSettings)
            let currentID = scheduler.currentWordID(for: Date(), schedule: schedule)
            let resolvedWord = filteredWords.first { $0.id == currentID } ?? {
                if let storedID = store.loadCurrentWordID() {
                    return filteredWords.first { $0.id == storedID }
                }
                return nil
            }() ?? filteredWords.first

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
            let source = try BundledWordSource(
                seenIDs: Set(store.loadSeenWordIDs()),
                loader: { filteredWords.isEmpty ? words : filteredWords }
            )
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
        print("Selected word:", word.source, "-", word.target)
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
        PronunciationService.shared.speak(word.source, localeIdentifier: word.sourceLanguage)
    }

    private var storeNeedsSetup: Bool {
        SharedWordStore.shared.loadScheduleSettings() == nil
    }

    private func applyFilters(to words: [WordEntry], settings: WordFilterSettings) -> [WordEntry] {
        words.filter { word in
            let levelMatch = settings.selectsAllLevels || settings.levels.contains(word.level)
            let categoryMatch = settings.selectsAllCategories || !Set(settings.categories).isDisjoint(with: word.categories)
            return levelMatch && categoryMatch
        }
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
            Text(example.source)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Text(example.target)
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
                        Text(word.source)
                            .font(.headline.weight(.semibold))
                        Text(word.target)
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
    @State private var selectedLevels: [String]
    @State private var selectedCategories: [String]
    @State private var selectedLanguageID: String

    let availableLevels: [String]
    let availableCategories: [String]
    let onSave: (WordScheduleSettings, WordFilterSettings, String) -> Void

    init(
        settings: WordScheduleSettings,
        filterSettings: WordFilterSettings,
        languageSelectionID: String,
        availableLevels: [String],
        availableCategories: [String],
        onSave: @escaping (WordScheduleSettings, WordFilterSettings, String) -> Void
    ) {
        _wordsPerDay = State(initialValue: settings.wordsPerDay)
        _startTime = State(initialValue: ScheduleSettingsView.dateFromMinutes(settings.startMinutes))
        _endTime = State(initialValue: ScheduleSettingsView.dateFromMinutes(settings.endMinutes))
        _selectedLevels = State(initialValue: filterSettings.levels)
        _selectedCategories = State(initialValue: filterSettings.categories)
        _selectedLanguageID = State(initialValue: languageSelectionID)
        self.availableLevels = availableLevels
        self.availableCategories = availableCategories
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

                Section("Language") {
                    Picker("Learning", selection: $selectedLanguageID) {
                        ForEach(LanguageCatalog.options, id: \.id) { option in
                            Text(option.label).tag(option.id)
                        }
                    }
                }

                Section("Levels") {
                    if availableLevels.isEmpty {
                        Text("No levels available.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(availableLevels, id: \.self) { level in
                            Toggle(isOn: bindingForLevel(level)) {
                                Text(level.capitalized)
                            }
                        }
                        Text("No selection = all levels")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Categories") {
                    if availableCategories.isEmpty {
                        Text("No categories available.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(availableCategories, id: \.self) { category in
                            Toggle(isOn: bindingForCategory(category)) {
                                Text(category)
                            }
                        }
                        Text("No selection = all categories")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let schedule = WordScheduleSettings(wordsPerDay: wordsPerDay, startMinutes: startMinutes, endMinutes: endMinutes)
                        let filters = WordFilterSettings(levels: selectedLevels, categories: selectedCategories)
                        onSave(schedule, filters, selectedLanguageID)
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

    private func bindingForLevel(_ level: String) -> Binding<Bool> {
        Binding(
            get: { selectedLevels.contains(level) },
            set: { isOn in
                if isOn {
                    if !selectedLevels.contains(level) {
                        selectedLevels.append(level)
                    }
                } else {
                    selectedLevels.removeAll { $0 == level }
                }
            }
        )
    }

    private func bindingForCategory(_ category: String) -> Binding<Bool> {
        Binding(
            get: { selectedCategories.contains(category) },
            set: { isOn in
                if isOn {
                    if !selectedCategories.contains(category) {
                        selectedCategories.append(category)
                    }
                } else {
                    selectedCategories.removeAll { $0 == category }
                }
            }
        )
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
