//
//  WordScheduler.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import Foundation

final class WordScheduler {
    private let words: [WordEntry]
    private let calendar: Calendar

    init(words: [WordEntry], calendar: Calendar = .current) {
        self.words = words
        self.calendar = calendar
    }

    func loadOrCreateSchedule(store: SharedWordStore, slotsPerDay: Int, startHour: Int, endHour: Int, now: Date = Date()) -> DailyWordSchedule {
        if let existing = store.loadSchedule(), calendar.isDate(existing.date, inSameDayAs: now) {
            return existing
        }

        let startOfDay = calendar.startOfDay(for: now)
        let slots = buildSlots(
            for: startOfDay,
            slotsPerDay: slotsPerDay,
            startHour: startHour,
            endHour: endHour,
            wordIDs: uniqueWordIDs(limit: slotsPerDay)
        )

        let schedule = DailyWordSchedule(date: startOfDay, slots: slots)
        store.saveSchedule(schedule)
        return schedule
    }

    func currentWordID(for now: Date, schedule: DailyWordSchedule) -> String? {
        guard !schedule.slots.isEmpty else {
            return nil
        }

        let sortedSlots = schedule.slots.sorted { $0.start < $1.start }
        var current: WordSlot?

        for slot in sortedSlots {
            if now >= slot.start {
                current = slot
            } else {
                break
            }
        }

        return current?.wordID ?? sortedSlots.first?.wordID
    }

    private func uniqueWordIDs(limit: Int) -> [String] {
        guard !words.isEmpty else {
            return []
        }

        let uniqueCount = min(limit, words.count)
        return Array(words.shuffled().prefix(uniqueCount)).map { $0.id }
    }

    private func buildSlots(for date: Date, slotsPerDay: Int, startHour: Int, endHour: Int, wordIDs: [String]) -> [WordSlot] {
        guard slotsPerDay > 0 else {
            return []
        }

        let hourCount = max(1, endHour - startHour)
        let intervalSeconds = (Double(hourCount) * 3600.0) / Double(max(1, slotsPerDay))

        var slots: [WordSlot] = []
        for index in 0..<min(slotsPerDay, wordIDs.count) {
            let offsetSeconds = Double(index) * intervalSeconds
            let start = calendar.date(byAdding: .second, value: Int(offsetSeconds), to: calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: date) ?? date) ?? date
            slots.append(WordSlot(start: start, wordID: wordIDs[index]))
        }

        return slots
    }
}
