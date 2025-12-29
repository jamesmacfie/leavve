//
//  AppState.swift
//  Leavve
//

import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var people: [Person] = []
    @Published var timeOffs: [TimeOff] = []
    @Published var holidayGroups: [HolidayGroup] = []
    @Published var settings: AppSettings = .default
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedPersonId: Int?

    private let storage = StorageService.shared
    private lazy var apiService: RunnAPIService = RunnAPIService(appState: self)
    private var refreshTimer: Timer?

    init() {
        loadFromStorage()
        setupAutoRefresh()
    }

    // MARK: - Computed Properties

    var activePeople: [Person] {
        people.filter { !$0.isArchived }
    }

    var visiblePeople: [Person] {
        activePeople
    }

    var peopleOnLeaveToday: [(person: Person, timeOff: TimeOff)] {
        timeOffs
            .filter { $0.isToday }
            .compactMap { timeOff in
                guard let person = people.first(where: { $0.id == timeOff.personId }),
                      !person.isArchived
                else { return nil }
                return (person, timeOff)
            }
            .sorted { $0.person.fullName < $1.person.fullName }
    }

    func upcomingTimeOffs(for personId: Int) -> [TimeOff] {
        timeOffs
            .filter { $0.personId == personId && ($0.isToday || $0.isUpcoming) }
            .sorted { $0.startDate < $1.startDate }
    }

    func holidayGroupName(for personId: Int) -> String? {
        guard let person = people.first(where: { $0.id == personId }),
              let groupId = person.holidaysGroupId,
              let group = holidayGroups.first(where: { $0.id == groupId })
        else { return nil }
        return group.displayName
    }

    // MARK: - Persistence

    func loadFromStorage() {
        people = storage.loadPeople()
        timeOffs = storage.loadTimeOffs()
        holidayGroups = storage.loadHolidayGroups()
        settings = storage.loadSettings()
    }

    func saveToStorage() {
        storage.savePeople(people)
        storage.saveTimeOffs(timeOffs)
        storage.saveHolidayGroups(holidayGroups)
        storage.saveSettings(settings)
    }

    // MARK: - Settings

    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        storage.saveSettings(settings)
    }

    func toggleEmployeeVisibility(_ personId: Int) {
        if settings.visibleEmployeeIds.contains(personId) {
            settings.visibleEmployeeIds.remove(personId)
        } else {
            settings.visibleEmployeeIds.insert(personId)
        }
        storage.saveSettings(settings)
    }

    // MARK: - Sync

    func sync() async {
        guard !settings.apiKey.isEmpty else {
            errorMessage = "API key not configured. Go to Settings."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await apiService.syncAll()
            settings.lastSyncDate = Date()
            saveToStorage()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Auto Refresh

    func setupAutoRefresh() {
        refreshTimer?.invalidate()

        guard let refreshTime = settings.autoRefreshTime else { return }

        let timer = Timer(fireAt: nextRefreshDate(for: refreshTime), interval: 24 * 60 * 60, target: self, selector: #selector(performScheduledSync), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        refreshTimer = timer
    }

    private func nextRefreshDate(for time: AppSettings.RefreshTime) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = time.hour
        components.minute = time.minute
        components.second = 0

        guard var date = calendar.date(from: components) else { return Date() }

        if date <= Date() {
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }

        return date
    }

    @objc private func performScheduledSync() {
        Task {
            await sync()
        }
    }

    func updateAutoRefreshTime(_ time: AppSettings.RefreshTime?) {
        settings.autoRefreshTime = time
        saveToStorage()
        setupAutoRefresh()
    }
}
