//
//  WordFilterSettings.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import Foundation

struct WordFilterSettings: Codable, Hashable {
    let levels: [String]
    let categories: [String]

    static let all = WordFilterSettings(levels: [], categories: [])

    var selectsAllLevels: Bool {
        levels.isEmpty
    }

    var selectsAllCategories: Bool {
        categories.isEmpty
    }
}
