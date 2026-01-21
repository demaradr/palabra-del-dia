//
//  BundledWordSource.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import Foundation

final class BundledWordSource {
    private let allWords: [WordEntry]
    private var seenIDs: Set<String>

    init(seenIDs: Set<String> = [], loader: () throws -> [WordEntry] = WordBundleLoader.load) throws {
        self.allWords = try loader()
        self.seenIDs = seenIDs
    }

    func nextWord() -> WordEntry? {
        guard !allWords.isEmpty else {
            return nil
        }

        if seenIDs.count >= allWords.count {
            seenIDs.removeAll()
        }

        let candidates = allWords.filter { !seenIDs.contains($0.id) }
        guard let next = candidates.randomElement() else {
            seenIDs.removeAll()
            return allWords.randomElement()
        }

        seenIDs.insert(next.id)
        return next
    }
}
