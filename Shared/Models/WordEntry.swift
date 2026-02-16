//
//  WordEntry.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import Foundation

struct ExampleSentence: Codable, Hashable {
    let source: String
    let target: String

    enum CodingKeys: String, CodingKey {
        case source
        case target
        case spanish
        case english
    }

    init(source: String, target: String) {
        self.source = source
        self.target = target
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.decodeIfPresent(String.self, forKey: .source)
            ?? container.decode(String.self, forKey: .spanish)
        target = try container.decodeIfPresent(String.self, forKey: .target)
            ?? container.decode(String.self, forKey: .english)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(target, forKey: .target)
    }
}

struct WordEntry: Codable, Identifiable, Hashable {
    let id: String
    let source: String
    let target: String
    let sourceLanguage: String
    let targetLanguage: String
    let examples: [ExampleSentence]
    let level: String
    let categories: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case source
        case target
        case sourceLanguage
        case targetLanguage
        case examples
        case level
        case categories
        case spanish
        case english
    }

    init(
        id: String,
        source: String,
        target: String,
        sourceLanguage: String,
        targetLanguage: String,
        examples: [ExampleSentence],
        level: String,
        categories: [String]
    ) {
        self.id = id
        self.source = source
        self.target = target
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.examples = examples
        self.level = level
        self.categories = categories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        source = try container.decodeIfPresent(String.self, forKey: .source)
            ?? container.decode(String.self, forKey: .spanish)
        target = try container.decodeIfPresent(String.self, forKey: .target)
            ?? container.decode(String.self, forKey: .english)
        sourceLanguage = try container.decodeIfPresent(String.self, forKey: .sourceLanguage) ?? "es-ES"
        targetLanguage = try container.decodeIfPresent(String.self, forKey: .targetLanguage) ?? "en-US"
        examples = try container.decodeIfPresent([ExampleSentence].self, forKey: .examples) ?? []
        level = try container.decodeIfPresent(String.self, forKey: .level) ?? "beginner"
        categories = try container.decodeIfPresent([String].self, forKey: .categories) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(source, forKey: .source)
        try container.encode(target, forKey: .target)
        try container.encode(sourceLanguage, forKey: .sourceLanguage)
        try container.encode(targetLanguage, forKey: .targetLanguage)
        try container.encode(examples, forKey: .examples)
        try container.encode(level, forKey: .level)
        try container.encode(categories, forKey: .categories)
    }
}
