//
//  WordScheduleSettings.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import Foundation

struct WordScheduleSettings: Codable, Hashable {
    let wordsPerDay: Int
    let startMinutes: Int
    let endMinutes: Int

    static let defaultSettings = WordScheduleSettings(wordsPerDay: 5, startMinutes: 7 * 60, endMinutes: 21 * 60)

    var crossesMidnight: Bool {
        endMinutes <= startMinutes
    }
}
