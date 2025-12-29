//
//  StorageService.swift
//  Leavve
//

import Foundation

class StorageService {
    static let shared = StorageService()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let people = "leavve_people"
        static let timeOffs = "leavve_timeoffs"
        static let holidayGroups = "leavve_holiday_groups"
        static let settings = "leavve_settings"
    }

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - People

    func savePeople(_ people: [Person]) {
        guard let data = try? encoder.encode(people) else { return }
        defaults.set(data, forKey: Keys.people)
    }

    func loadPeople() -> [Person] {
        guard let data = defaults.data(forKey: Keys.people),
              let people = try? decoder.decode([Person].self, from: data) else {
            return []
        }
        return people
    }

    // MARK: - Time Offs

    func saveTimeOffs(_ timeOffs: [TimeOff]) {
        guard let data = try? encoder.encode(timeOffs) else { return }
        defaults.set(data, forKey: Keys.timeOffs)
    }

    func loadTimeOffs() -> [TimeOff] {
        guard let data = defaults.data(forKey: Keys.timeOffs),
              let timeOffs = try? decoder.decode([TimeOff].self, from: data) else {
            return []
        }
        return timeOffs
    }

    // MARK: - Holiday Groups

    func saveHolidayGroups(_ groups: [HolidayGroup]) {
        guard let data = try? encoder.encode(groups) else { return }
        defaults.set(data, forKey: Keys.holidayGroups)
    }

    func loadHolidayGroups() -> [HolidayGroup] {
        guard let data = defaults.data(forKey: Keys.holidayGroups),
              let groups = try? decoder.decode([HolidayGroup].self, from: data) else {
            return []
        }
        return groups
    }

    // MARK: - Settings

    func saveSettings(_ settings: AppSettings) {
        guard let data = try? encoder.encode(settings) else { return }
        defaults.set(data, forKey: Keys.settings)
    }

    func loadSettings() -> AppSettings {
        guard let data = defaults.data(forKey: Keys.settings),
              let settings = try? decoder.decode(AppSettings.self, from: data) else {
            return .default
        }
        return settings
    }
}
