//
//  WordEntry.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import Foundation

struct ExampleSentence: Codable, Hashable {
    let spanish: String
    let english: String
}

struct WordEntry: Codable, Identifiable, Hashable {
    let id: String
    let spanish: String
    let english: String
    let examples: [ExampleSentence]

    enum CodingKeys: String, CodingKey {
        case id
        case spanish
        case english
        case examples
    }

    init(id: String, spanish: String, english: String, examples: [ExampleSentence]) {
        self.id = id
        self.spanish = spanish
        self.english = english
        self.examples = examples
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        spanish = try container.decode(String.self, forKey: .spanish)
        english = try container.decode(String.self, forKey: .english)
        examples = try container.decodeIfPresent([ExampleSentence].self, forKey: .examples) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(spanish, forKey: .spanish)
        try container.encode(english, forKey: .english)
        try container.encode(examples, forKey: .examples)
    }
}
