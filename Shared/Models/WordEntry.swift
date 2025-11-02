//
//  WordEntry.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import Foundation

struct Example: Codable, Hashable {
    let es: String
    let en: String?
}

struct WordEntry: Codable, Identifiable, Hashable {
    let id: String
    let lemma: String
    let pos: String
    let region: String
    let translation_en: String
    let definition_es: String
    let examples: [Example]
    let frequency_rank: Int?
}
