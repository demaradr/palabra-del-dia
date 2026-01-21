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
}
