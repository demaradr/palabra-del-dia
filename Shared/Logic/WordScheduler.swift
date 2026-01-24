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

    func loadOrCreateSchedule(store: SharedWordStore, settings: WordScheduleSettings, now: Date = Date()) -> DailyWordSchedule {
        let anchorDate = scheduleAnchorDate(for: now, settings: settings)

        if let existing = store.loadSchedule(), calendar.isDate(existing.date, inSameDayAs: anchorDate) {
            return existing
        }

        let startOfDay = calendar.startOfDay(for: anchorDate)
        let slots = buildSlots(
            for: startOfDay,
            slotsPerDay: settings.wordsPerDay,
            startMinutes: settings.startMinutes,
            endMinutes: settings.endMinutes,
            wordIDs: uniqueWordIDs(limit: settings.wordsPerDay)
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

        return current?.wordID
    }

    private func uniqueWordIDs(limit: Int) -> [String] {
        guard !words.isEmpty else {
            return []
        }

        let uniqueCount = min(limit, words.count)
        return Array(words.shuffled().prefix(uniqueCount)).map { $0.id }
    }

    private func buildSlots(for date: Date, slotsPerDay: Int, startMinutes: Int, endMinutes: Int, wordIDs: [String]) -> [WordSlot] {
        guard slotsPerDay > 0 else {
            return []
        }

        let start = max(0, min(startMinutes, 24 * 60))
        let end = max(0, min(endMinutes, 24 * 60))
        let totalMinutes = end <= start ? (24 * 60 - start) + end : (end - start)
        let intervalSeconds = (Double(max(1, totalMinutes)) * 60.0) / Double(max(1, slotsPerDay))

        var slots: [WordSlot] = []
        for index in 0..<min(slotsPerDay, wordIDs.count) {
            let offsetSeconds = Double(index) * intervalSeconds
            let startDate = calendar.date(byAdding: .minute, value: start, to: date) ?? date
            let slotStart = calendar.date(byAdding: .second, value: Int(offsetSeconds), to: startDate) ?? startDate
            slots.append(WordSlot(start: slotStart, wordID: wordIDs[index]))
        }

        return slots
    }

    private func scheduleAnchorDate(for now: Date, settings: WordScheduleSettings) -> Date {
        let startOfDay = calendar.startOfDay(for: now)
        guard settings.crossesMidnight else {
            return startOfDay
        }

        let minutesNow = minutesSinceStartOfDay(now)
        if minutesNow < settings.endMinutes {
            return calendar.date(byAdding: .day, value: -1, to: startOfDay) ?? startOfDay
        }

        return startOfDay
    }

    private func minutesSinceStartOfDay(_ date: Date) -> Int {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }
}
