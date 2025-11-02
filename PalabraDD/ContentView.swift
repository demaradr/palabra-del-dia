//
//  ContentView.swift
//  PalabraDD
//

import SwiftUI

struct ContentView: View {
    // When true, we show mock data and skip loading from disk (great for Previews)
    let useMockData: Bool

    @State private var status: String = "Loading…"
    @State private var firstWord: WordEntry?

    init(useMockData: Bool = false) {
        self.useMockData = useMockData
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            // Title / status
            Text(firstWord?.lemma ?? "Hello, Palabrify!")
                .font(.title2).bold()

            if let w = firstWord {
                Text(w.translation_en)
                    .foregroundStyle(.secondary)
            } else {
                Text(status)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        // Only do the expensive load when not in mock/preview mode
        .task {
            guard !useMockData else {
                // Lightweight mock so the preview shows something instantly
                firstWord = WordEntry(
                    id: "hablar",
                    lemma: "hablar",
                    pos: "verb",
                    region: "es-ES",
                    translation_en: "to speak; to talk",
                    definition_es: "Comunicar ideas mediante palabras.",
                    examples: [Example(es: "Quiero hablar contigo.", en: "I want to talk with you.")],
                    frequency_rank: 512
                )
                status = "Preview (mock data)"
                return
            }

            do {
                let words = try WordBundleLoader.load()
                print("Loaded words: \(words.count)")
                if let first = words.first {
                    print("First word:", first.lemma, "-", first.translation_en)
                }
                firstWord = words.first
                status = "Loaded \(words.count) words"
            } catch {
                status = "Load error: \(error.localizedDescription)"
                print("Load error:", error)
            }
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
