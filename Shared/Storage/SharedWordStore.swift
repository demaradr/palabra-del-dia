//
//  SharedWordStore.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import Foundation

enum AppGroup {
    static let id = "group.Demartin.PalabraDD.shared"
}

struct WordSlot: Codable, Hashable {
    let start: Date
    let wordID: String
}

struct DailyWordSchedule: Codable, Hashable {
    let date: Date
    let slots: [WordSlot]
}

final class SharedWordStore {
    static let shared = SharedWordStore()

    private let defaults: UserDefaults
    let isAppGroupAvailable: Bool

    init() {
        if let groupDefaults = UserDefaults(suiteName: AppGroup.id),
           FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroup.id) != nil {
            self.defaults = groupDefaults
            self.isAppGroupAvailable = true
        } else {
            self.defaults = .standard
            self.isAppGroupAvailable = false
        }
    }

    func loadSeenWordIDs() -> [String] {
        defaults.stringArray(forKey: Keys.seenWordIDs) ?? []
    }

    func saveSeenWordIDs(_ ids: [String]) {
        defaults.set(ids, forKey: Keys.seenWordIDs)
    }

    func markSeen(_ id: String) {
        var ids = Set(loadSeenWordIDs())
        ids.insert(id)
        saveSeenWordIDs(Array(ids))
    }

    func loadCurrentWordID() -> String? {
        defaults.string(forKey: Keys.currentWordID)
    }

    func saveCurrentWordID(_ id: String?) {
        defaults.set(id, forKey: Keys.currentWordID)
    }

    func loadSchedule() -> DailyWordSchedule? {
        loadCodable(forKey: Keys.dailySchedule)
    }

    func saveSchedule(_ schedule: DailyWordSchedule?) {
        saveCodable(schedule, forKey: Keys.dailySchedule)
    }

    private func loadCodable<T: Decodable>(forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(T.self, from: data)
    }

    private func saveCodable<T: Encodable>(_ value: T?, forKey key: String) {
        guard let value else {
            defaults.removeObject(forKey: key)
            return
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try? encoder.encode(value)
        defaults.set(data, forKey: key)
    }

    private enum Keys {
        static let seenWordIDs = "seenWordIDs"
        static let currentWordID = "currentWordID"
        static let dailySchedule = "dailySchedule"
    }
}
